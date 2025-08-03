//
//  UserService.swift
//  HeyBoomerangIOS
//
//  Created by Claude on 8/2/25.
//

import Foundation

// MARK: - Profile API Response Models

struct ProfileAPIResponse: Codable {
    let success: Bool
    let user: ProfileAPIUser?
    let message: String
}

struct ProfileAPIUser: Codable {
    let id: String
    let email: String
    let businessName: String?
    let businessType: String?
    let businessDescription: String?
    let phoneNumber: String?
    let timezone: String?
    let subscriptionStatus: String
    let trialEndsAt: String?
    let createdAt: String
    let updatedAt: String
}

// MARK: - User Management Service

final class UserService: UserServiceProtocol, ObservableObject {
    private let apiService: APIServiceProtocol
    private let storage: SecureStorageProtocol
    private let authService: SupabaseAuthService
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var lastError: AppError?
    
    init(apiService: APIServiceProtocol, storage: SecureStorageProtocol, authService: SupabaseAuthService = SupabaseAuthService.shared) {
        self.apiService = apiService
        self.storage = storage
        self.authService = authService
        
        // Listen to auth state changes
        setupAuthListener()
        
        // Load cached user on initialization
        Task {
            await loadCachedUser()
        }
    }
    
    private func setupAuthListener() {
        // Listen to SupabaseAuthService authentication changes
        Task { @MainActor in
            // Use a timer to periodically check auth state
            // This is a simple approach - in production you'd use Combine publishers
            while true {
                let wasAuthenticated = isAuthenticated
                isAuthenticated = authService.isAuthenticated
                
                // If authentication state changed, fetch user profile
                if !wasAuthenticated && isAuthenticated {
                    Task {
                        await fetchUserProfile()
                    }
                } else if wasAuthenticated && !isAuthenticated {
                    // User logged out
                    currentUser = nil
                }
                
                try? await Task.sleep(for: .seconds(1)) // Check every 1 second
            }
        }
    }
    
    private func fetchUserProfile() async {
        guard authService.isAuthenticated else { return }
        
        Logger.shared.info("Fetching user profile from backend", category: .api)
        
        // Call backend API to get user profile
        guard let url = URL(string: "https://heyboomerang-v5.vercel.app/api/user/profile") else {
            Logger.shared.error("Invalid profile URL", category: .api)
            return
        }
        
        guard let accessToken = authService.accessToken else {
            Logger.shared.error("No access token available", category: .api)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("👤 User profile fetch response: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    // Parse the user profile
                    let decoder = JSONDecoder()
                    let profileResponse = try decoder.decode(ProfileAPIResponse.self, from: data)
                    
                    if let userProfile = profileResponse.user {
                        // Convert String ID to UUID (Supabase uses UUID strings)
                        let userId = UUID(uuidString: userProfile.id) ?? UUID()
                        
                        let user = User(
                            id: userId,
                            email: userProfile.email,
                            businessName: userProfile.businessName ?? "My Business",
                            businessType: userProfile.businessType ?? "Service Business",
                            timezone: userProfile.timezone ?? "America/New_York",
                            subscriptionStatus: userProfile.subscriptionStatus
                        )
                        
                        await MainActor.run {
                            self.currentUser = user
                        }
                        
                        // Cache the user
                        try? await storage.store(user, forKey: "current_user")
                        
                        Logger.shared.info("User profile loaded: \(user.email)", category: .api)
                    }
                }
            }
        } catch {
            Logger.shared.error("Failed to fetch user profile", error: error, category: .api)
        }
    }
    
    // MARK: - Public Interface
    
    func getCurrentUser() async -> Result<User?, AppError> {
        Logger.shared.info("Getting current user", category: .api)
        
        // First check if we have a cached user
        if let cachedUser = currentUser {
            Logger.shared.debug("Returning cached user: \(cachedUser.email)", category: .api)
            return .success(cachedUser)
        }
        
        // Try to load from storage
        if let storedUser = await loadCachedUser() {
            Logger.shared.debug("Returning stored user: \(storedUser.email)", category: .api)
            return .success(storedUser)
        }
        
        Logger.shared.debug("No user found", category: .api)
        return .success(nil)
    }
    
    func updateUserProfile(_ user: User) async -> Result<User, AppError> {
        Logger.shared.info("Updating user profile for: \(user.email)", category: .api)
        
        await MainActor.run {
            isLoading = true
            lastError = nil
        }
        
        // For now, simulate API call since we're in prototype phase
        // In production, this would make an actual API call
        
        do {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            // Update local storage
            try storage.store(user, forKey: StorageKey.userProfile)
            
            await MainActor.run {
                currentUser = user
                isAuthenticated = true
                isLoading = false
            }
            
            Logger.shared.info("Successfully updated user profile", category: .api)
            return .success(user)
            
        } catch {
            await MainActor.run {
                isLoading = false
                lastError = AppError.storage(.saveFailed(error.localizedDescription))
            }
            
            Logger.shared.error("Failed to update user profile", error: error, category: .api)
            return .failure(AppError.storage(.saveFailed(error.localizedDescription)))
        }
    }
    
    func signOut() async -> Result<Void, AppError> {
        Logger.shared.info("Signing out user", category: .api)
        
        do {
            // Clear stored user data
            try storage.delete(forKey: StorageKey.userProfile)
            
            // Clear sensitive data from keychain
            try? storage.deleteFromKeychain(forKey: StorageKey.authToken)
            try? storage.deleteFromKeychain(forKey: StorageKey.refreshToken)
            
            await MainActor.run {
                currentUser = nil
                isAuthenticated = false
                lastError = nil
            }
            
            Logger.shared.info("Successfully signed out", category: .api)
            return .success(())
            
        } catch {
            Logger.shared.error("Failed to sign out", error: error, category: .api)
            return .failure(AppError.storage(.saveFailed(error.localizedDescription)))
        }
    }
    
    // MARK: - Onboarding & Setup
    
    func createUserProfile(
        email: String,
        businessName: String?,
        businessType: String?,
        city: String?,
        state: String?
    ) async -> Result<User, AppError> {
        Logger.shared.info("Creating user profile for: \(email)", category: .api)
        
        // Input validation
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let error = AppError.validation(.emptyInput("Email"))
            await MainActor.run { lastError = error }
            return .failure(error)
        }
        
        guard isValidEmail(email) else {
            let error = AppError.validation(.invalidEmail)
            await MainActor.run { lastError = error }
            return .failure(error)
        }
        
        let newUser = User(
            email: email,
            businessName: businessName,
            businessType: businessType,
            city: city,
            state: state,
            timezone: TimeZone.current.identifier,
            subscriptionStatus: "trial",
            trialEndsAt: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
            dailyCaptureCount: 0,
            dailyCaptureReset: Date()
        )
        
        return await updateUserProfile(newUser)
    }
    
    func completeOnboarding() async -> Result<Void, AppError> {
        Logger.shared.info("Completing onboarding", category: .api)
        
        do {
            try storage.store(true, forKey: StorageKey.onboardingCompleted)
            Logger.shared.info("Onboarding completed", category: .api)
            return .success(())
        } catch {
            Logger.shared.error("Failed to complete onboarding", error: error, category: .api)
            return .failure(AppError.storage(.saveFailed(error.localizedDescription)))
        }
    }
    
    func isOnboardingCompleted() -> Bool {
        do {
            return try storage.retrieve(Bool.self, forKey: StorageKey.onboardingCompleted)
        } catch {
            return false
        }
    }
    
    // MARK: - Daily Capture Management
    
    func incrementDailyCaptureCount() async -> Result<Int, AppError> {
        guard var user = currentUser else {
            let error = AppError.validation(.emptyInput("User"))
            return .failure(error)
        }
        
        // Check if we need to reset the daily count
        let calendar = Calendar.current
        let now = Date()
        
        if let resetDate = user.dailyCaptureReset,
           !calendar.isDate(resetDate, inSameDayAs: now) {
            // Reset count for new day
            user = User(
                id: user.id,
                email: user.email,
                businessName: user.businessName,
                businessType: user.businessType,
                city: user.city,
                state: user.state,
                timezone: user.timezone,
                subscriptionStatus: user.subscriptionStatus,
                trialEndsAt: user.trialEndsAt,
                dailyCaptureCount: 1,
                dailyCaptureReset: now
            )
        } else {
            // Increment existing count
            user = User(
                id: user.id,
                email: user.email,
                businessName: user.businessName,
                businessType: user.businessType,
                city: user.city,
                state: user.state,
                timezone: user.timezone,
                subscriptionStatus: user.subscriptionStatus,
                trialEndsAt: user.trialEndsAt,
                dailyCaptureCount: user.dailyCaptureCount + 1,
                dailyCaptureReset: user.dailyCaptureReset
            )
        }
        
        let result = await updateUserProfile(user)
        switch result {
        case .success(let updatedUser):
            return .success(updatedUser.dailyCaptureCount)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - Private Methods
    
    @discardableResult
    private func loadCachedUser() async -> User? {
        do {
            let user = try storage.retrieve(User.self, forKey: StorageKey.userProfile)
            await MainActor.run {
                currentUser = user
                isAuthenticated = true
            }
            Logger.shared.debug("Loaded cached user: \(user.email)", category: .storage)
            return user
        } catch {
            Logger.shared.debug("No cached user found", category: .storage)
            return nil
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
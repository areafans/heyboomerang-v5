//
//  SupabaseAuthService.swift
//  HeyBoomerangIOS
//
//  Created by Claude on 8/2/25.
//

import Foundation
import Supabase

// MARK: - Supabase Configuration and Auth Service

final class SupabaseAuthService: ObservableObject {
    static let shared = SupabaseAuthService()
    
    // Supabase client - you'll need to add the Supabase package first
    private let client: SupabaseClient
    
    @Published var currentSession: Session?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    private init() {
        // Initialize Supabase client
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://vzcqwvxzkorejjrvdylh.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ6Y3F3dnh6a29yZWpqcnZkeWxoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQxNTY0OTYsImV4cCI6MjA2OTczMjQ5Nn0.6D_yiL7BiE_N1_krpToxN4U2cUXbpVUtPKWm5FDLBvs"
        )
        
        // Listen for auth state changes
        setupAuthListener()
    }
    
    // MARK: - Auth State Management
    
    private func setupAuthListener() {
        Task {
            for await (_, session) in client.auth.authStateChanges {
                await MainActor.run {
                    self.currentSession = session
                    self.isAuthenticated = session != nil
                }
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    func signUpWithEmail(email: String, password: String) async throws {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            try await client.auth.signUp(email: email, password: password)
            
            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
            }
            throw error
        }
    }
    
    func signInWithEmail(email: String, password: String) async throws {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            try await client.auth.signIn(email: email, password: password)
            
            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
            }
            throw error
        }
    }
    
    // Remove old magic link callback method since we're not using it anymore
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    // MARK: - Session Management
    
    var accessToken: String? {
        return currentSession?.accessToken
    }
    
    var user: Supabase.User? {
        return currentSession?.user
    }
    
    // MARK: - User Profile Management
    
    func updateUserProfile(businessName: String, businessType: String, businessDescription: String) async throws {
        guard let accessToken = accessToken else {
            throw AuthError.notAuthenticated
        }
        
        // Call our backend API to update profile
        guard let url = URL(string: "https://heyboomerang-v5.vercel.app/api/user/profile") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let body = [
            "businessName": businessName,
            "businessType": businessType,
            "businessDescription": businessDescription
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AuthError.profileUpdateFailed
        }
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case notAuthenticated
    case invalidURL
    case profileUpdateFailed
    case callbackFailed
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated"
        case .invalidURL:
            return "Invalid URL"
        case .profileUpdateFailed:
            return "Failed to update user profile"
        case .callbackFailed:
            return "Authentication callback failed"
        }
    }
}
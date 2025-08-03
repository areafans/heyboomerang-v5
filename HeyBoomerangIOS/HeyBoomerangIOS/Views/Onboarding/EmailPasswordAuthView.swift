//
//  EmailPasswordAuthView.swift
//  HeyBoomerangIOS
//
//  Created by Claude on 8/3/25.
//

import SwiftUI

struct EmailPasswordAuthView: View {
    @Binding var isCompleted: Bool
    @ObservedObject var onboardingData: OnboardingData
    @StateObject private var authService = SupabaseAuthService.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password, confirmPassword
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                        .symbolRenderingMode(.hierarchical)
                    
                    Text(isSignUp ? "Create Account" : "Sign In")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(isSignUp ? "Create your account to get started with Boomerang" : "Sign in to your Boomerang account")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 20) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your email address", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .keyboardType(.emailAddress)
                            .focused($focusedField, equals: .email)
                            .onSubmit {
                                focusedField = .password
                            }
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                            .focused($focusedField, equals: .password)
                            .onSubmit {
                                if isSignUp {
                                    focusedField = .confirmPassword
                                } else {
                                    signIn()
                                }
                            }
                    }
                    
                    // Confirm Password Field (Sign Up Only)
                    if isSignUp {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("Confirm your password", text: $confirmPassword)
                                .textFieldStyle(.roundedBorder)
                                .font(.body)
                                .focused($focusedField, equals: .confirmPassword)
                                .onSubmit {
                                    signUp()
                                }
                        }
                    }
                    
                    // Error Message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading)
                    }
                    
                    // Main Action Button
                    Button(action: isSignUp ? signUp : signIn) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Text(isSignUp ? "Create Account" : "Sign In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading || !isFormValid)
                    
                    // Toggle Sign Up/Sign In
                    Button(action: {
                        withAnimation {
                            isSignUp.toggle()
                            errorMessage = ""
                            password = ""
                            confirmPassword = ""
                        }
                    }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 10)
                    
                    // Social Sign In Buttons
                    VStack(spacing: 12) {
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.secondary.opacity(0.3))
                            Text("or")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.secondary.opacity(0.3))
                        }
                        .padding(.vertical, 10)
                        
                        // Apple Sign In Button
                        Button(action: signInWithApple) {
                            HStack {
                                Image(systemName: "applelogo")
                                Text("Continue with Apple")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundColor(.white)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // Google Sign In Button
                        Button(action: signInWithGoogle) {
                            HStack {
                                Image(systemName: "globe")
                                Text("Continue with Google")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundColor(.primary)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer(minLength: 50)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onTapGesture {
            focusedField = nil
        }
        .onAppear {
            // Auto-focus email field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .email
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        let emailValid = !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isValidEmail(email)
        let passwordValid = password.count >= 6
        
        if isSignUp {
            return emailValid && passwordValid && password == confirmPassword
        } else {
            return emailValid && passwordValid
        }
    }
    
    // MARK: - Authentication Methods
    
    private func signUp() {
        guard isFormValid else {
            errorMessage = "Please fill in all fields correctly"
            return
        }
        
        isLoading = true
        errorMessage = ""
        focusedField = nil
        
        Task {
            do {
                try await authService.signUpWithEmail(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
                
                await MainActor.run {
                    // Store user data and complete onboarding
                    onboardingData.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
                    completeAuthentication()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to create account: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func signIn() {
        guard isFormValid else {
            errorMessage = "Please enter a valid email and password"
            return
        }
        
        isLoading = true
        errorMessage = ""
        focusedField = nil
        
        Task {
            do {
                try await authService.signInWithEmail(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
                
                await MainActor.run {
                    // Store user data and complete onboarding
                    onboardingData.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
                    completeAuthentication()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to sign in: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func signInWithApple() {
        errorMessage = "Apple Sign In coming soon!"
        // TODO: Implement Apple Sign In
    }
    
    private func signInWithGoogle() {
        errorMessage = "Google Sign In coming soon!"
        // TODO: Implement Google Sign In
    }
    
    private func completeAuthentication() {
        // Store authentication data
        if let accessToken = authService.accessToken,
           let userId = authService.user?.id {
            onboardingData.accessToken = accessToken
            onboardingData.userId = userId.uuidString
            
            // Create user profile in backend
            Task {
                await createUserProfile()
            }
        } else {
            isLoading = false
            errorMessage = "Authentication succeeded but failed to get user data"
        }
    }
    
    private func createUserProfile() async {
        guard let accessToken = authService.accessToken else {
            await MainActor.run {
                isLoading = false
                errorMessage = "No access token available"
            }
            return
        }
        
        // Call backend to create user profile
        guard let url = URL(string: "https://heyboomerang-v5.vercel.app/api/user/profile") else {
            await MainActor.run {
                isLoading = false
                errorMessage = "Invalid backend URL"
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"  // Use POST to create new user
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let body = [
            "email": onboardingData.email,
            "businessName": onboardingData.businessName,
            "businessType": "Service Business",
            "businessDescription": onboardingData.businessDescription
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("👤 User profile creation response: \(httpResponse.statusCode)")
                
                await MainActor.run {
                    isLoading = false
                    if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                        withAnimation {
                            isCompleted = true
                        }
                    } else {
                        errorMessage = "Profile created but backend sync failed (code: \(httpResponse.statusCode))"
                    }
                }
            }
        } catch {
            print("👤 User profile creation error: \(error)")
            await MainActor.run {
                isLoading = false
                // Don't block the user - complete anyway but show warning
                withAnimation {
                    isCompleted = true
                }
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    EmailPasswordAuthView(isCompleted: .constant(false), onboardingData: OnboardingData())
}
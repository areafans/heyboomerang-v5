//
//  EmailAuthView.swift
//  HeyBoomerangIOS
//
//  Created by Claude on 8/2/25.
//

import SwiftUI

struct EmailAuthView: View {
    @Binding var isCompleted: Bool
    @ObservedObject var onboardingData: OnboardingData
    @StateObject private var authService = SupabaseAuthService.shared
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var errorMessage = ""
    @FocusState private var isEmailFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                        .symbolRenderingMode(.hierarchical)
                    
                    Text("Connect your account")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("We'll send you a secure link to sign in. Your business info will sync automatically.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                if !showSuccess {
                    // Email Input
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email Address")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your email address", text: $onboardingData.email)
                                .textFieldStyle(.roundedBorder)
                                .font(.body)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .keyboardType(.emailAddress)
                                .focused($isEmailFocused)
                                .submitLabel(.send)
                                .onSubmit {
                                    sendMagicLink()
                                }
                        }
                        .padding(.horizontal, 24)
                        
                        // Error Message
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 24)
                        }
                        
                        // Send Link Button
                        Button(action: sendMagicLink) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                } else {
                                    Text("Send Secure Link")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(onboardingData.email.isEmpty || isLoading)
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                    }
                } else {
                    // Success State
                    VStack(spacing: 24) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        VStack(spacing: 12) {
                            Text("Check your email!")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("We sent a secure link to:")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Text(onboardingData.email)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                        
                        VStack(spacing: 16) {
                            Text("Tap the link in your email to continue. It may take a few minutes to arrive.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            Button("Resend Link") {
                                sendMagicLink()
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        
                        // Manual Continue for Testing
                        Button("I clicked the link - Continue") {
                            completeAuthentication()
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer(minLength: 50)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onTapGesture {
            isEmailFocused = false
        }
        .onAppear {
            // Auto-focus email field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isEmailFocused = true
            }
        }
    }
    
    private func sendMagicLink() {
        let email = onboardingData.email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address"
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        isLoading = true
        errorMessage = ""
        isEmailFocused = false
        
        // Update the email in onboarding data (cleaned)
        onboardingData.email = email
        
        // Use Supabase Auth to send magic link
        Task {
            do {
                try await authService.signInWithMagicLink(email: email)
                
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to send email: \(error.localizedDescription)"
                }
            }
        }
    }
    
    
    private func completeAuthentication() {
        // Check if user is authenticated via Supabase
        if authService.isAuthenticated, 
           let accessToken = authService.accessToken,
           let userId = authService.user?.id.uuidString {
            
            // Store authentication data
            onboardingData.accessToken = accessToken
            onboardingData.userId = userId
            
            // Update user profile with business information
            Task {
                do {
                    try await authService.updateUserProfile(
                        businessName: onboardingData.businessName,
                        businessType: "Service Business", // Default for now
                        businessDescription: onboardingData.businessDescription
                    )
                    
                    await MainActor.run {
                        // Complete authentication step
                        withAnimation {
                            isCompleted = true
                        }
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = "Failed to update profile: \(error.localizedDescription)"
                    }
                }
            }
        } else {
            errorMessage = "Please complete authentication first by clicking the email link"
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    EmailAuthView(isCompleted: .constant(false), onboardingData: OnboardingData())
}
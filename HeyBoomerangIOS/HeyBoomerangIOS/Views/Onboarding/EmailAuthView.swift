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
        
        // Call our backend API to send magic link
        Task {
            do {
                let success = try await sendMagicLinkAPI(email: email)
                
                await MainActor.run {
                    isLoading = false
                    if success {
                        showSuccess = true
                    } else {
                        errorMessage = "Failed to send email. Please try again."
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Network error. Please check your connection and try again."
                }
            }
        }
    }
    
    private func sendMagicLinkAPI(email: String) async throws -> Bool {
        guard let url = URL(string: "https://heyboomerang-v5.vercel.app/api/auth/signin") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }
        
        if httpResponse.statusCode == 200 {
            return true
        } else {
            // Log the error for debugging
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorData["error"] as? String {
                print("Magic link error: \(error)")
            }
            return false
        }
    }
    
    private func completeAuthentication() {
        // For now, just complete the onboarding step
        // In a full implementation, this would verify the authentication token
        withAnimation {
            isCompleted = true
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
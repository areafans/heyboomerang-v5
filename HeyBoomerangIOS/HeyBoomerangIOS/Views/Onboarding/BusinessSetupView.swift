//
//  BusinessSetupView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct BusinessSetupView: View {
    @Binding var isCompleted: Bool
    @ObservedObject var onboardingData: OnboardingData
    @FocusState private var focusedField: Field?
    @State private var isKeyboardVisible = false
    
    enum Field {
        case userName, businessName, businessDescription
    }
    
    var body: some View {
        ZStack {
            ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "storefront.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                        .symbolRenderingMode(.hierarchical)
                    
                    Text("Set up your business")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Help us personalize your experience and generate better follow-ups")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // Form Fields
                VStack(spacing: 20) {
                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your name", text: $onboardingData.userName)
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled(true)
                            .focused($focusedField, equals: .userName)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .businessName
                            }
                    }
                    
                    // Business Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Business Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your business name", text: $onboardingData.businessName)
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled(true)
                            .focused($focusedField, equals: .businessName)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .businessDescription
                            }
                    }
                    
                    // Business Description Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What does your business do?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Help us understand your business so we can generate relevant follow-ups")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("e.g., We're a general contracting company specializing in home renovations and kitchen remodels", text: $onboardingData.businessDescription, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...5)
                            .font(.body)
                            .textInputAutocapitalization(.sentences)
                            .autocorrectionDisabled(true)
                            .focused($focusedField, equals: .businessDescription)
                            .submitLabel(.return)
                    }
                }
                .padding(.horizontal, 24)
                
                // Continue Button
                Button("Continue") {
                    completeSetup()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .disabled(!canContinue)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                }
                .padding(.bottom, 100) // Extra padding for keyboard
            }
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture {
                focusedField = nil
            }
            
            // Floating Done button when keyboard is visible
            if isKeyboardVisible {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button("Done") {
                            focusedField = nil
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onChange(of: focusedField) { oldValue, newValue in
            withAnimation(.easeInOut(duration: 0.3)) {
                isKeyboardVisible = newValue != nil
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isKeyboardVisible = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isKeyboardVisible = false
            }
        }
    }
    
    private var canContinue: Bool {
        onboardingData.hasBusinessInfo
    }
    
    private func completeSetup() {
        // Business data is already stored in onboardingData
        print("Business Setup Complete:")
        print("User: \(onboardingData.userName)")
        print("Business: \(onboardingData.businessName)")
        print("Description: \(onboardingData.businessDescription)")
        
        // Dismiss keyboard first
        focusedField = nil
        
        // Complete setup with animation
        withAnimation {
            isCompleted = true
        }
    }
}

#Preview {
    BusinessSetupView(isCompleted: .constant(false), onboardingData: OnboardingData())
}
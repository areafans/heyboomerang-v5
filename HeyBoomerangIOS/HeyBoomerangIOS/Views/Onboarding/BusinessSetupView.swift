//
//  BusinessSetupView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct BusinessSetupView: View {
    @Binding var isCompleted: Bool
    @State private var userName = ""
    @State private var businessName = ""
    @State private var businessDescription = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case userName, businessName, businessDescription
    }
    
    var body: some View {
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
                        
                        TextField("Enter your name", text: $userName)
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
                        
                        TextField("Enter your business name", text: $businessName)
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
                        
                        TextField("e.g., We're a general contracting company specializing in home renovations and kitchen remodels", text: $businessDescription, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...5)
                            .font(.body)
                            .textInputAutocapitalization(.sentences)
                            .autocorrectionDisabled(true)
                            .focused($focusedField, equals: .businessDescription)
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
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                if focusedField == .businessDescription {
                    Spacer()
                    Button("Done") {
                        // Just dismiss keyboard - let user see form and manually tap Continue
                        focusedField = nil
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var canContinue: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !businessName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !businessDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func completeSetup() {
        // Mock saving business data
        print("Business Setup Complete:")
        print("User: \(userName)")
        print("Business: \(businessName)")
        print("Description: \(businessDescription)")
        
        // Dismiss keyboard first
        focusedField = nil
        
        // Complete setup with animation
        withAnimation {
            isCompleted = true
        }
    }
}

#Preview {
    BusinessSetupView(isCompleted: .constant(false))
}
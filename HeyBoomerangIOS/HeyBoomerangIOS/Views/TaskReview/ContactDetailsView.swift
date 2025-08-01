//
//  ContactDetailsView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 8/1/25.
//

import SwiftUI

struct ContactDetailsView: View {
    let contact: Contact
    @Binding var phone: String
    @Binding var email: String
    let onContinue: () -> Void
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case phone, email
    }
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 16) {
                Text(contact.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Add contact details to send message")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Contact Details Form
            VStack(spacing: 24) {
                // Phone Field
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.blue)
                            .symbolRenderingMode(.hierarchical)
                        
                        Text("Phone Number")
                            .font(.headline)
                    }
                    
                    TextField("(555) 123-4567", text: $phone)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)
                        .focused($focusedField, equals: .phone)
                        .onAppear {
                            // Pre-fill if contact already has phone
                            if let existingPhone = contact.phone {
                                phone = existingPhone
                            }
                        }
                }
                
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.blue)
                            .symbolRenderingMode(.hierarchical)
                        
                        Text("Email Address")
                            .font(.headline)
                    }
                    
                    TextField("name@example.com", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .email)
                        .onAppear {
                            // Pre-fill if contact already has email
                            if let existingEmail = contact.email {
                                email = existingEmail
                            }
                        }
                }
                
                // Helper text
                Text("Add at least one contact method to continue")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Continue Button
            VStack(spacing: 16) {
                Button("Continue") {
                    onContinue()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .disabled(!canContinue)
                
                Button("Skip this task") {
                    // Skip action - for future implementation
                }
                .foregroundColor(.secondary)
            }
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
        .navigationTitle("Contact Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
    
    private var canContinue: Bool {
        !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    NavigationView {
        ContactDetailsView(
            contact: Contact(userId: UUID(), name: "Mary Johnson"),
            phone: .constant(""),
            email: .constant(""),
            onContinue: {}
        )
    }
}
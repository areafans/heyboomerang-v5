//
//  ContactDisambiguationView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 8/1/25.
//

import SwiftUI

struct ContactDisambiguationView: View {
    let task: ReviewTask
    let onSelectContact: (Contact) -> Void
    
    @State private var selectedContactId: UUID?
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 16) {
                Text("Follow-up 1 of 5")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\"\(task.contactName)\"")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Did you mean?")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Contact Options
            VStack(spacing: 16) {
                ForEach(task.suggestedContacts) { contact in
                    ContactOptionRow(
                        contact: contact,
                        isSelected: selectedContactId == contact.id,
                        onTap: {
                            selectedContactId = contact.id
                        }
                    )
                }
            }
            
            Spacer()
            
            // Continue Button
            Button("Continue") {
                if let selectedId = selectedContactId,
                   let selectedContact = task.suggestedContacts.first(where: { $0.id == selectedId }) {
                    onSelectContact(selectedContact)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
            .disabled(selectedContactId == nil)
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
        .navigationTitle("Contact")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Pre-select first contact if it has complete info
            if let firstContact = task.suggestedContacts.first,
               firstContact.phone != nil || firstContact.email != nil {
                selectedContactId = firstContact.id
            }
        }
    }
}

struct ContactOptionRow: View {
    let contact: Contact
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Selection indicator
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.blue : Color.secondary, lineWidth: 2)
                        )
                    
                    if isSelected {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Contact info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(contact.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if contact.phone == nil && contact.email == nil {
                            Text("New")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    
                    if let phone = contact.phone {
                        Text("📱 \(phone)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let email = contact.email {
                        Text("✉️ \(email)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if contact.phone == nil && contact.email == nil {
                        Text("Will add contact details next")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        ContactDisambiguationView(
            task: ReviewTask(
                contactName: "Mary Johns",
                message: "Thanks for letting us work on your kitchen demo today!",
                isAmbiguous: true,
                suggestedContacts: [
                    Contact(userId: UUID(), name: "Mary Johnson", email: "mary.j@email.com", phone: "555-0123"),
                    Contact(userId: UUID(), name: "Mary Johns", email: nil, phone: nil)
                ]
            ),
            onSelectContact: { _ in }
        )
    }
}
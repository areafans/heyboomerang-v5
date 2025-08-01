//
//  MessagePreviewView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 8/1/25.
//

import SwiftUI

struct MessagePreviewView: View {
    let task: ReviewTask
    let contact: Contact
    let timing: TaskReviewFlow.TimingOption
    let onApprove: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 16) {
                Text("Ready to send")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Review the final message before sending")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Message Details
            VStack(spacing: 24) {
                // Recipient
                VStack(alignment: .leading, spacing: 12) {
                    Text("To:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Text(String(contact.name.prefix(1)))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(contact.name)
                                .font(.headline)
                            
                            if let phone = contact.phone, !phone.isEmpty {
                                Text("📱 \(phone)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let email = contact.email, !email.isEmpty {
                                Text("✉️ \(email)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Message
                VStack(alignment: .leading, spacing: 12) {
                    Text("Message:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(task.message)
                        .font(.body)
                        .padding(16)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // Timing
                VStack(alignment: .leading, spacing: 12) {
                    Text("When:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.green)
                            .symbolRenderingMode(.hierarchical)
                        
                        Text(timingDescription)
                            .font(.body)
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                Button("Approve ✓") {
                    onApprove()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                
                Button("Skip this task") {
                    onSkip()
                }
                .foregroundColor(.secondary)
            }
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
        .navigationTitle("Final Review")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var timingDescription: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        
        switch timing {
        case .tomorrowAM:
            return formatter.string(from: Date().addingTimeInterval(86400)) + " at 10:00 AM"
        case .tomorrowPM:
            return formatter.string(from: Date().addingTimeInterval(86400)) + " at 2:00 PM"
        case .inTwoDays:
            return formatter.string(from: Date().addingTimeInterval(172800)) + " at 10:00 AM"
        }
    }
}

#Preview {
    NavigationView {
        MessagePreviewView(
            task: ReviewTask(
                contactName: "Mary Johnson",
                message: "Thanks for letting us work on your kitchen demo today! The project is off to a great start."
            ),
            contact: Contact(
                userId: UUID(),
                name: "Mary Johnson",
                email: "mary.j@email.com",
                phone: "555-0123"
            ),
            timing: .tomorrowAM,
            onApprove: {},
            onSkip: {}
        )
    }
}
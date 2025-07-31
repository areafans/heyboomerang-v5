//
//  PermissionsView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct PermissionsView: View {
    @Binding var isCompleted: Bool
    @State private var microphoneGranted = false
    @State private var speechGranted = false
    @State private var notificationsGranted = false
    @State private var currentStep = 0
    
    private let permissions = [
        (
            icon: "mic.fill",
            title: "Microphone Access",
            description: "Record your voice notes throughout the day",
            systemPrompt: "Boomerang needs microphone access to capture your voice notes"
        ),
        (
            icon: "brain.head.profile",
            title: "Speech Recognition",
            description: "Convert your voice into text for task generation",
            systemPrompt: "Boomerang uses speech recognition to understand your voice notes"
        ),
        (
            icon: "bell.fill",
            title: "Notifications",
            description: "Remind you to review tasks each evening",
            systemPrompt: "Get notified when tasks are ready for review"
        )
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 16) {
                Text("Enable Permissions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Boomerang needs a few permissions to work properly")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Permissions List
            VStack(spacing: 24) {
                ForEach(Array(permissions.enumerated()), id: \.offset) { index, permission in
                    PermissionRow(
                        icon: permission.icon,
                        title: permission.title,
                        description: permission.description,
                        isGranted: getPermissionStatus(for: index),
                        onTap: {
                            requestPermission(at: index, systemPrompt: permission.systemPrompt)
                        }
                    )
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Continue Button
            VStack(spacing: 16) {
                Button("Continue to App") {
                    withAnimation {
                        isCompleted = true
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .disabled(!allPermissionsGranted)
                
                if !allPermissionsGranted {
                    Text("Please enable all permissions to continue")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .padding(.top, 20)
    }
    
    private func getPermissionStatus(for index: Int) -> Bool {
        switch index {
        case 0: return microphoneGranted
        case 1: return speechGranted
        case 2: return notificationsGranted
        default: return false
        }
    }
    
    private var allPermissionsGranted: Bool {
        microphoneGranted && speechGranted && notificationsGranted
    }
    
    private func requestPermission(at index: Int, systemPrompt: String) {
        // Mock permission request - in real app this would trigger system dialogs
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                switch index {
                case 0: microphoneGranted = true
                case 1: speechGranted = true
                case 2: notificationsGranted = true
                default: break
                }
            }
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isGranted ? Color.green : Color.blue)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: isGranted ? "checkmark" : icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Status
                if !isGranted {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(isGranted)
    }
}

#Preview {
    PermissionsView(isCompleted: .constant(false))
}
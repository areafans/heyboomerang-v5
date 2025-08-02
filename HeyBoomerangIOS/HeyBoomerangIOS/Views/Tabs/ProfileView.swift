//
//  ProfileView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct ProfileView: View {
    // Mock user data
    @State private var userName = "Mike Thompson"
    @State private var businessName = "Thompson Construction"
    @State private var businessDescription = "General contracting company specializing in home renovations and kitchen remodels"
    @State private var subscriptionStatus = "7-day free trial"
    @State private var trialDaysRemaining = 5
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(userName.prefix(1))
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            )
                        
                        VStack(spacing: 4) {
                            Text(userName)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(businessName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Subscription Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Subscription")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(subscriptionStatus)
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                if trialDaysRemaining > 0 {
                                    Text("\(trialDaysRemaining) days left")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.orange.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                            
                            if trialDaysRemaining > 0 {
                                Button("Upgrade to Pro") {
                                    // Handle upgrade
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                            }
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    
                    // Business Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Business Information")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 16) {
                            ProfileRow(title: "Business Name", value: businessName)
                            ProfileRow(title: "Description", value: businessDescription)
                            
                            Button("Edit Business Info") {
                                // Handle edit
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    
                    // Settings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Settings")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 0) {
                            SettingsRow(icon: "bell.fill", title: "Notifications", action: {})
                            Divider().padding(.leading, 44)
                            SettingsRow(icon: "square.and.arrow.up.fill", title: "Export Data", action: {})
                            Divider().padding(.leading, 44)
                            SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", action: {})
                            Divider().padding(.leading, 44)
                            SettingsRow(icon: "info.circle.fill", title: "About", action: {})
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarHidden(true)
        }
    }
}

struct ProfileRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(value)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .frame(width: 28)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfileView()
}
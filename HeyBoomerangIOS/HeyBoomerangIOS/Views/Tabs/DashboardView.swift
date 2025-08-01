//
//  DashboardView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct DashboardView: View {
    // Mock metrics data
    @State private var weeklyMessages = 23
    @State private var monthlyMessages = 87
    @State private var completionRate = 0.84
    @State private var topContacts = ["Johnson Family", "Miller Family", "Williams Project"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Weekly Overview
                    VStack(alignment: .leading, spacing: 16) {
                        Text("This Week")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            MetricCard(
                                title: "Messages Sent",
                                value: "\(weeklyMessages)",
                                subtitle: "This week",
                                color: .blue
                            )
                            
                            MetricCard(
                                title: "Completion Rate",
                                value: "\(Int(completionRate * 100))%",
                                subtitle: "Tasks approved",
                                color: .green
                            )
                        }
                    }
                    
                    // Monthly Overview
                    VStack(alignment: .leading, spacing: 16) {
                        Text("This Month")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        MetricCard(
                            title: "Total Messages",
                            value: "\(monthlyMessages)",
                            subtitle: "Messages sent this month",
                            color: .purple,
                            fullWidth: true
                        )
                    }
                    
                    // Top Contacts
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Top Contacts")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 12) {
                            ForEach(Array(topContacts.enumerated()), id: \.offset) { index, contact in
                                HStack {
                                    Text("\(index + 1)")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    
                                    Text(contact)
                                        .font(.body)
                                    
                                    Spacer()
                                    
                                    Text("\(Int.random(in: 3...8)) messages")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                                
                                if index < topContacts.count - 1 {
                                    Divider()
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    var fullWidth: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: fullWidth ? .infinity : nil, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    DashboardView()
}
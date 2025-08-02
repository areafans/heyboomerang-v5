//
//  SummaryView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct SummaryView: View {
    // Mock data for previous day's completed actions
    @State private var completedMessages = [
        CompletedMessage(contactName: "Johnson Family", type: "Follow-up SMS", status: "Delivered", sentAt: Date().addingTimeInterval(-3600), response: nil),
        CompletedMessage(contactName: "Miller Family", type: "Follow-up SMS", status: "Read", sentAt: Date().addingTimeInterval(-7200), response: "Yes, let's schedule next week!"),
        CompletedMessage(contactName: "Supplier - ABC Materials", type: "Call Reminder", status: "Delivered", sentAt: Date().addingTimeInterval(-10800), response: nil)
    ]
    
    private var userName: String = "Mike" // In real app, would come from user data
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if completedMessages.isEmpty {
                        // Empty state
                        VStack(spacing: 16) {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                                .symbolRenderingMode(.hierarchical)
                            
                            Text("Good morning, \(userName)! ☀️")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Your completed messages will appear here each morning")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        // Morning greeting
                        VStack(spacing: 8) {
                            Text("Good morning, \(userName)! ☀️")
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("While you slept, your business was working...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Hero Impact Section
                        heroImpactCard
                        
                        // Hot Leads Section
                        if !hotLeads.isEmpty {
                            hotLeadsSection
                        }
                        
                        // Message Results
                        messageResultsSection
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Boomerang")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .refreshable {
                // Simulate refresh - in real app would fetch new data
            }
        }
    }
    
    // MARK: - Hero Impact Cards
    private var heroImpactCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                Text("Yesterday's Impact")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 8) {
                // Messages sent card
                ImpactCard(
                    icon: "paperplane.fill",
                    iconColor: .blue,
                    text: "\(completedMessages.count) message\(completedMessages.count == 1 ? "" : "s") sent",
                    backgroundColor: Color.blue.opacity(0.1)
                )
                
                // Responses received card
                if responseCount > 0 {
                    ImpactCard(
                        icon: "bubble.right.fill",
                        iconColor: .green,
                        text: "\(responseCount) response\(responseCount == 1 ? "" : "s") received",
                        backgroundColor: Color.green.opacity(0.1)
                    )
                    
                    // Potential bookings card
                    ImpactCard(
                        icon: "target",
                        iconColor: .orange,
                        text: "\(responseCount) potential booking\(responseCount == 1 ? "" : "s")",
                        backgroundColor: Color.orange.opacity(0.1)
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Hot Leads Section
    private var hotLeadsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("Ready for Follow-up")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 8) {
                ForEach(hotLeads) { lead in
                    HotLeadCard(message: lead)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Message Results Section
    private var messageResultsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("All Messages")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(deliveryRate)% delivered")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 8) {
                ForEach(completedMessages) { message in
                    SimpleMessageRow(message: message)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Computed Properties
    private var responseCount: Int {
        completedMessages.filter { $0.response != nil }.count
    }
    
    private var hotLeads: [CompletedMessage] {
        completedMessages.filter { $0.response != nil }
    }
    
    private var deliveryRate: Int {
        let delivered = completedMessages.filter { $0.status != "Failed" }.count
        return completedMessages.isEmpty ? 0 : Int((Double(delivered) / Double(completedMessages.count)) * 100)
    }
}

// MARK: - Supporting Views

struct ImpactCard: View {
    let icon: String
    let iconColor: Color
    let text: String
    let backgroundColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(iconColor)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(backgroundColor)
        .cornerRadius(8)
    }
}

struct HotLeadCard: View {
    let message: CompletedMessage
    
    var body: some View {
        HStack(spacing: 12) {
            // Hot indicator
            Circle()
                .fill(Color.orange)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(message.contactName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("replied!")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
                
                if let response = message.response {
                    Text("\"\(response)\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .italic()
                }
                
                Text("→ Schedule call today")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
            }
        }
        .padding(12)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

struct SimpleMessageRow: View {
    let message: CompletedMessage
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            // Contact and type
            Text(message.contactName)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text("•")
                .foregroundColor(.secondary)
                .font(.caption)
            
            Text(message.type)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Status and time
            VStack(alignment: .trailing, spacing: 2) {
                Text(message.status)
                    .font(.caption)
                    .foregroundColor(statusColor)
                    .fontWeight(.medium)
                
                Text(timeFormatter.string(from: message.sentAt))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var statusColor: Color {
        switch message.status {
        case "Read": return .green
        case "Delivered": return .blue
        case "Failed": return .red
        default: return .gray
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

// MARK: - Data Models

struct CompletedMessage: Identifiable {
    let id = UUID()
    let contactName: String
    let type: String
    let status: String // "Delivered", "Read", "Failed"
    let sentAt: Date
    let response: String? // New field for client responses
}

#Preview {
    SummaryView()
}
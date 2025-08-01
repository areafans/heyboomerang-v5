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
        CompletedMessage(contactName: "Johnson Family", type: "Follow-up", status: "Delivered", sentAt: Date().addingTimeInterval(-3600)),
        CompletedMessage(contactName: "Miller Family", type: "Follow-up", status: "Read", sentAt: Date().addingTimeInterval(-7200)),
        CompletedMessage(contactName: "Supplier", type: "Reminder", status: "Delivered", sentAt: Date().addingTimeInterval(-10800))
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if completedMessages.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Nothing sent yet")
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
                    // Results from previous day
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(completedMessages) { message in
                                CompletedMessageRow(message: message)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .refreshable {
                        // Simulate refresh - in real app would fetch new data
                    }
                }
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct CompletedMessage: Identifiable {
    let id = UUID()
    let contactName: String
    let type: String
    let status: String // "Delivered", "Read", "Failed"
    let sentAt: Date
}

struct CompletedMessageRow: View {
    let message: CompletedMessage
    
    var body: some View {
        HStack(spacing: 16) {
            // Status icon
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: statusIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(statusColor)
                    .symbolRenderingMode(.hierarchical)
            }
            
            // Message details
            VStack(alignment: .leading, spacing: 4) {
                Text(message.contactName)
                    .font(.headline)
                
                Text(message.type)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(message.status)
                    .font(.caption)
                    .foregroundColor(statusColor)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            // Time
            Text(timeFormatter.string(from: message.sentAt))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var statusColor: Color {
        switch message.status {
        case "Read": return .green
        case "Delivered": return .blue
        case "Failed": return .red
        default: return .gray
        }
    }
    
    private var statusIcon: String {
        switch message.status {
        case "Read": return "checkmark.circle.fill"
        case "Delivered": return "paperplane.fill"
        case "Failed": return "exclamationmark.triangle.fill"
        default: return "circle"
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    SummaryView()
}
//
//  TasksView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct TasksView: View {
    @State private var pendingTasks = [
        PendingTask(contactName: "Johnson Family", type: "Follow-up", message: "Thanks for letting us work on your kitchen demo today! The project is off to a great start."),
        PendingTask(contactName: "Miller Family", type: "Follow-up", message: "Hi! Just wanted to follow up about your deck project. When would be a good time to schedule?"),
        PendingTask(contactName: "Supplier", type: "Reminder", message: "Remember to order drywall for the Williams project next week.")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if pendingTasks.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("All caught up!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("New tasks from your voice captures will appear here for review")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    // Header summary
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(pendingTasks.count) tasks ready for review")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Review and approve to send automatically")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    // Tasks list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(pendingTasks) { task in
                                PendingTaskRow(task: task) {
                                    // Remove task when approved
                                    if let index = pendingTasks.firstIndex(where: { $0.id == task.id }) {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            pendingTasks.remove(at: index)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .refreshable {
                        // Simulate refresh - in real app would fetch new tasks
                    }
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct PendingTask: Identifiable {
    let id = UUID()
    let contactName: String
    let type: String
    let message: String
}

struct PendingTaskRow: View {
    let task: PendingTask
    let onApprove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.contactName)
                        .font(.headline)
                    
                    Text(task.type)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                // Type badge with icon
                HStack(spacing: 4) {
                    Image(systemName: task.type == "Follow-up" ? "arrow.turn.up.right" : "bell.fill")
                        .font(.caption2)
                        .symbolRenderingMode(.hierarchical)
                    
                    Text(task.type)
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .foregroundColor(.blue)
                .cornerRadius(8)
            }
            
            // Message preview
            Text(task.message)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(3)
            
            // Action buttons
            HStack(spacing: 12) {
                Button("Skip") {
                    // Skip task
                    onApprove()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                
                Button("Approve") {
                    // Approve task
                    onApprove()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    TasksView()
}
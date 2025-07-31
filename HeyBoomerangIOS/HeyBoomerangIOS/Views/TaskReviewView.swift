//
//  TaskReviewView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct TaskReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var tasks: [Task] = []
    @State private var currentTaskIndex = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if tasks.isEmpty {
                    // Empty State
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("All caught up!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("No tasks to review right now")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Task Review Flow
                    VStack(spacing: 16) {
                        // Progress Indicator
                        HStack {
                            Text("Task \(currentTaskIndex + 1) of \(tasks.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("Skip All") {
                                // Skip remaining tasks
                            }
                            .font(.caption)
                        }
                        
                        // Current Task
                        if currentTaskIndex < tasks.count {
                            let task = tasks[currentTaskIndex]
                            
                            VStack(spacing: 20) {
                                // Task Type Badge
                                HStack {
                                    Text(task.type.rawValue.capitalized)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(8)
                                    
                                    Spacer()
                                }
                                
                                // Contact Name
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Contact:")
                                        .font(.headline)
                                    
                                    Text(task.contactName ?? "Unknown Contact")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Message Preview
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Message:")
                                        .font(.headline)
                                    
                                    Text(task.message)
                                        .font(.body)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Spacer()
                                
                                // Action Buttons
                                HStack(spacing: 16) {
                                    Button("Skip") {
                                        skipCurrentTask()
                                    }
                                    .buttonStyle(.bordered)
                                    .frame(maxWidth: .infinity)
                                    
                                    Button("Approve") {
                                        approveCurrentTask()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Review Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadTasks()
        }
    }
    
    private func loadTasks() {
        // Mock data for now
        tasks = [
            Task(userId: UUID(), captureId: UUID(), type: .followUp, contactName: "Mary Johnson", message: "Thanks for coming in today! Hope you love your new look. Let me know if you need any touch-ups."),
            Task(userId: UUID(), captureId: UUID(), type: .reminder, contactName: "Store Manager", message: "Remember to order more shampoo for next week's appointments."),
            Task(userId: UUID(), captureId: UUID(), type: .followUp, contactName: "Sarah Williams", message: "Hi Sarah! Just wanted to follow up on your appointment today. How are you feeling about the new style?")
        ]
    }
    
    private func skipCurrentTask() {
        if currentTaskIndex < tasks.count - 1 {
            currentTaskIndex += 1
        } else {
            dismiss()
        }
    }
    
    private func approveCurrentTask() {
        // TODO: Submit to API
        if currentTaskIndex < tasks.count - 1 {
            currentTaskIndex += 1
        } else {
            dismiss()
        }
    }
}

#Preview {
    TaskReviewView()
}
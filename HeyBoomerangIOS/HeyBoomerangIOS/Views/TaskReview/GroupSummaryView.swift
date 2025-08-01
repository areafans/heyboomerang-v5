//
//  GroupSummaryView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 8/1/25.
//

import SwiftUI

struct GroupSummaryView: View {
    let taskGroups: [TaskGroup]
    let onSelectGroup: (TaskReviewFlow.TaskType) -> Void
    
    private var totalTasks: Int {
        taskGroups.reduce(0) { $0 + $1.tasks.count }
    }
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 16) {
                Text("\(totalTasks) tasks ready")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Review and approve to send automatically")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Task Groups
            VStack(spacing: 24) {
                ForEach(taskGroups, id: \.type) { group in
                    TaskGroupRow(
                        group: group,
                        onTap: {
                            onSelectGroup(group.type)
                        }
                    )
                }
            }
            
            Spacer()
            
            // Bulk Actions (for future implementation)
            VStack(spacing: 16) {
                Button("Approve All Follow-ups") {
                    // Bulk approve action
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                .disabled(taskGroups.first(where: { $0.type == .followUp })?.tasks.isEmpty ?? true)
                
                Text("Or review each task individually above")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
        .navigationTitle("Task Review")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TaskGroupRow: View {
    let group: TaskGroup
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: group.type.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.blue)
                        .symbolRenderingMode(.hierarchical)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(group.type.displayName) (\(group.tasks.count))")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(group.tasks.isEmpty ? "No tasks" : "Tap to review")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(group.tasks.isEmpty)
        .opacity(group.tasks.isEmpty ? 0.6 : 1.0)
    }
}

#Preview {
    NavigationView {
        GroupSummaryView(
            taskGroups: [
                TaskGroup(type: .followUp, tasks: [
                    ReviewTask(contactName: "Mary Johns", message: "Test message 1"),
                    ReviewTask(contactName: "Johnson Family", message: "Test message 2"),
                    ReviewTask(contactName: "Miller Family", message: "Test message 3"),
                    ReviewTask(contactName: "Wilson Project", message: "Test message 4"),
                    ReviewTask(contactName: "Davis Home", message: "Test message 5")
                ]),
                TaskGroup(type: .reminder, tasks: [
                    ReviewTask(contactName: "Self", message: "Test reminder 1"),
                    ReviewTask(contactName: "Self", message: "Test reminder 2"),
                    ReviewTask(contactName: "Self", message: "Test reminder 3")
                ]),
                TaskGroup(type: .note, tasks: [
                    ReviewTask(contactName: "General", message: "Test note 1"),
                    ReviewTask(contactName: "General", message: "Test note 2"),
                    ReviewTask(contactName: "General", message: "Test note 3"),
                    ReviewTask(contactName: "General", message: "Test note 4")
                ])
            ],
            onSelectGroup: { _ in }
        )
    }
}
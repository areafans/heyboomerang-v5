//
//  TasksView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import SwiftUI

struct TasksView: View {
    @Binding var pendingTasksCount: Int
    @State private var pendingTasks: [AppTask] = []
    @State private var showingCardView = false
    @State private var selectedTaskIndex = 0
    @StateObject private var taskService = DependencyContainer.shared.taskService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                // Page Header (like Capture page)
                VStack(spacing: 8) {
                    Text("\(pendingTasks.count) tasks ready for review")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Tap any task to review and approve")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                
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
                    // Task section header (like Summary page style)
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "list.bullet.clipboard")
                                .foregroundColor(.blue)
                            Text("Pending Tasks")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Tasks list
                        ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(Array(pendingTasks.enumerated()), id: \.element.id) { index, task in
                                TaskListRow(task: task) {
                                    selectedTaskIndex = index
                                    showingCardView = true
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
            }
            .navigationTitle("Boomerang")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .fullScreenCover(isPresented: $showingCardView) {
                TaskCardStackView(
                    tasks: $pendingTasks,
                    startingIndex: selectedTaskIndex,
                    pendingTasksCount: $pendingTasksCount
                )
            }
            .onAppear {
                loadRealTasks()
            }
        }
    }
    
    private func loadRealTasks() {
        print("🔄 Loading real tasks from TaskService...")
        
        Task {
            let result = await taskService.loadPendingTasks()
            
            await MainActor.run {
                switch result {
                case .success(let tasks):
                    print("✅ Loaded \(tasks.count) real tasks")
                    pendingTasks = tasks
                    pendingTasksCount = tasks.count
                case .failure(let error):
                    print("❌ Failed to load tasks: \(error)")
                    // For now, show empty state instead of mock data
                    pendingTasks = []
                    pendingTasksCount = 0
                }
            }
        }
    }
}

struct TaskListRow: View {
    let task: AppTask
    let onTap: () -> Void
    
    private var taskColor: Color {
        switch task.type.color {
        case "blue": return .blue
        case "orange": return .orange
        case "purple": return .purple
        case "green": return .green
        case "indigo": return .indigo
        default: return .blue
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Type icon
                Image(systemName: task.type.icon)
                    .font(.title3)
                    .foregroundColor(taskColor)
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 24, height: 24)
                
                // Task summary
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(task.contactName ?? "Unknown Contact")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Type label
                        Text(task.type.displayName)
                            .font(.caption)
                            .foregroundColor(taskColor)
                            .fontWeight(.medium)
                    }
                    
                    // Brief message preview
                    Text(task.message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TasksView(pendingTasksCount: .constant(5))
}
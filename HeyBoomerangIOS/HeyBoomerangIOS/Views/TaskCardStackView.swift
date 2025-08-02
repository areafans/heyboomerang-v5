//
//  TaskCardStackView.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 8/2/25.
//

import SwiftUI

struct TaskCardStackView: View {
    @Binding var tasks: [Task]
    @State private var currentIndex: Int
    @Binding var pendingTasksCount: Int
    @Environment(\.dismiss) private var dismiss
    
    init(tasks: Binding<[Task]>, startingIndex: Int, pendingTasksCount: Binding<Int>) {
        self._tasks = tasks
        self._currentIndex = State(initialValue: startingIndex)
        self._pendingTasksCount = pendingTasksCount
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if tasks.isEmpty {
                    // All tasks completed
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        
                        Text("All tasks reviewed!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Great job staying on top of your communications")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if currentIndex < tasks.count {
                    let task = tasks[currentIndex]
                    
                    // Progress indicator
                    VStack(spacing: 16) {
                        HStack {
                            Text("Task \(currentIndex + 1) of \(tasks.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            // Progress bar
                            ProgressView(value: Double(currentIndex + 1), total: Double(tasks.count))
                                .frame(width: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Task Card
                        TaskCard(task: task) { action in
                            handleTaskAction(action)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                } else {
                    // Shouldn't happen, but fallback
                    VStack {
                        Text("No more tasks")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Review Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back to List") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip All") {
                        skipAllRemainingTasks()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    // Swipe left/right to navigate between cards
                    if value.translation.width > 50 && currentIndex > 0 {
                        // Swipe right - go to previous task
                        withAnimation(.spring()) {
                            currentIndex -= 1
                        }
                    } else if value.translation.width < -50 && currentIndex < tasks.count - 1 {
                        // Swipe left - go to next task
                        withAnimation(.spring()) {
                            currentIndex += 1
                        }
                    }
                }
        )
    }
    
    private func handleTaskAction(_ action: TaskAction) {
        switch action {
        case .approve:
            approveCurrentTask()
        case .skip:
            skipCurrentTask()
        }
    }
    
    private func approveCurrentTask() {
        guard currentIndex < tasks.count else { return }
        
        withAnimation {
            // Remove the approved task
            tasks.remove(at: currentIndex)
            pendingTasksCount = tasks.count
            
            // Adjust current index if needed
            if currentIndex >= tasks.count && currentIndex > 0 {
                currentIndex = tasks.count - 1
            }
        }
        
        // If no more tasks, dismiss after a brief delay
        if tasks.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        }
    }
    
    private func skipCurrentTask() {
        guard currentIndex < tasks.count else { return }
        
        withAnimation {
            // Remove the skipped task  
            tasks.remove(at: currentIndex)
            pendingTasksCount = tasks.count
            
            // Adjust current index if needed
            if currentIndex >= tasks.count && currentIndex > 0 {
                currentIndex = tasks.count - 1
            }
        }
        
        // If no more tasks, dismiss after a brief delay
        if tasks.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        }
    }
    
    private func skipAllRemainingTasks() {
        tasks.removeAll()
        pendingTasksCount = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}

enum TaskAction {
    case approve
    case skip
}

struct TaskCard: View {
    let task: Task
    let onAction: (TaskAction) -> Void
    
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
        VStack(spacing: 0) {
            // Card Header with type and contact
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: task.type.icon)
                                .font(.headline)
                                .foregroundColor(taskColor)
                                .symbolRenderingMode(.hierarchical)
                            
                            Text(task.type.displayName)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(taskColor)
                        }
                        
                        Text(task.contactName ?? "Unknown Contact")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
                
                Divider()
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            // Voice Context Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "mic.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("You said:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                Text("\"\(task.originalTranscription)\"")
                    .font(.body)
                    .foregroundColor(.primary)
                    .italic()
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // Generated Task Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Generated task:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                Text(task.message)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(taskColor.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(task.type.actionButtonText) {
                    onAction(.approve)
                }
                .buttonStyle(PrimaryActionButtonStyle(color: taskColor))
                
                Button("Skip") {
                    onAction(.skip)
                }
                .buttonStyle(SecondaryActionButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(color)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    TaskCardStackView(
        tasks: .constant([
            Task(
                userId: UUID(),
                captureId: UUID(),
                type: .followUpSMS,
                contactName: "Johnson Family",
                message: "Thanks for letting us work on your kitchen demo today! The project is off to a great start.",
                originalTranscription: "Just finished the kitchen demo at the Johnson house"
            )
        ]),
        startingIndex: 0,
        pendingTasksCount: .constant(1)
    )
}
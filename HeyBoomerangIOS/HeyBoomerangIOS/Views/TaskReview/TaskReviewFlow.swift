//
//  TaskReviewFlow.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 8/1/25.
//

import SwiftUI

struct TaskReviewFlow: View {
    @State private var currentStep: ReviewStep = .groupSummary
    @State private var currentTaskType: TaskType = .followUp
    @State private var currentTaskIndex = 0
    @State private var selectedContact: Contact?
    @State private var contactPhone = ""
    @State private var contactEmail = ""
    @State private var selectedTiming: TimingOption = .tomorrowAM
    
    // Mock data matching PRD examples
    @State private var taskGroups = [
        TaskGroup(type: .followUp, tasks: [
            ReviewTask(contactName: "Mary Johns", message: "Thanks for letting us work on your kitchen demo today! The project is off to a great start.", isAmbiguous: true, suggestedContacts: [
                Contact(userId: UUID(), name: "Mary Johnson", email: "mary.j@email.com", phone: "555-0123"),
                Contact(userId: UUID(), name: "Mary Johns", email: nil, phone: nil)
            ]),
            ReviewTask(contactName: "Johnson Family", message: "Hi! Just wanted to follow up about your deck project. When would be a good time to schedule?"),
            ReviewTask(contactName: "Miller Family", message: "Great meeting with you today about the bathroom renovation. We'll have the quote ready by Friday."),
            ReviewTask(contactName: "Wilson Project", message: "The drywall installation went smoothly today. Next step is painting on Monday."),
            ReviewTask(contactName: "Davis Home", message: "Thanks for choosing us for your flooring project. The materials will arrive Thursday.")
        ]),
        TaskGroup(type: .reminder, tasks: [
            ReviewTask(contactName: "Self", message: "Remember to order drywall for the Williams project next week."),
            ReviewTask(contactName: "Self", message: "Follow up with lumber supplier about delivery delay."),
            ReviewTask(contactName: "Self", message: "Schedule inspection for the Thompson kitchen remodel.")
        ]),
        TaskGroup(type: .note, tasks: [
            ReviewTask(contactName: "General", message: "Weather looks good for outdoor projects this week."),
            ReviewTask(contactName: "General", message: "New apprentice John starts Monday - prepare orientation materials."),
            ReviewTask(contactName: "General", message: "Business license renewal due next month."),
            ReviewTask(contactName: "General", message: "Consider purchasing new tile saw for upcoming projects.")
        ])
    ]
    
    enum ReviewStep {
        case groupSummary
        case contactDisambiguation
        case contactDetails
        case timingSelection
        case messagePreview
    }
    
    enum TaskType: CaseIterable {
        case followUp
        case reminder
        case note
        
        var displayName: String {
            switch self {
            case .followUp: return "Follow-ups"
            case .reminder: return "Reminders"
            case .note: return "Notes"
            }
        }
        
        var icon: String {
            switch self {
            case .followUp: return "arrow.turn.up.right"
            case .reminder: return "bell.fill"
            case .note: return "note.text"
            }
        }
    }
    
    enum TimingOption: CaseIterable {
        case tomorrowAM
        case tomorrowPM
        case inTwoDays
        
        var displayName: String {
            switch self {
            case .tomorrowAM: return "Tomorrow AM"
            case .tomorrowPM: return "Tomorrow PM"
            case .inTwoDays: return "In 2 days"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                switch currentStep {
                case .groupSummary:
                    GroupSummaryView(
                        taskGroups: taskGroups,
                        onSelectGroup: { taskType in
                            currentTaskType = taskType
                            currentTaskIndex = 0
                            
                            // Check if first task needs disambiguation
                            let firstTask = taskGroups.first(where: { $0.type == taskType })?.tasks.first
                            if firstTask?.isAmbiguous == true {
                                currentStep = .contactDisambiguation
                            } else {
                                currentStep = .contactDetails
                            }
                        }
                    )
                
                case .contactDisambiguation:
                    ContactDisambiguationView(
                        task: currentTask,
                        onSelectContact: { contact in
                            selectedContact = contact
                            currentStep = .contactDetails
                        }
                    )
                
                case .contactDetails:
                    ContactDetailsView(
                        contact: selectedContact ?? Contact(userId: UUID(), name: currentTask.contactName),
                        phone: $contactPhone,
                        email: $contactEmail,
                        onContinue: {
                            currentStep = .timingSelection
                        }
                    )
                
                case .timingSelection:
                    TimingSelectionView(
                        task: currentTask,
                        selectedTiming: $selectedTiming,
                        onContinue: {
                            currentStep = .messagePreview
                        }
                    )
                
                case .messagePreview:
                    MessagePreviewView(
                        task: currentTask,
                        contact: selectedContact ?? Contact(userId: UUID(), name: currentTask.contactName),
                        timing: selectedTiming,
                        onApprove: {
                            approveCurrentTask()
                        },
                        onSkip: {
                            skipCurrentTask()
                        }
                    )
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private var currentTaskGroup: TaskGroup {
        taskGroups.first(where: { $0.type == currentTaskType }) ?? taskGroups[0]
    }
    
    private var currentTask: ReviewTask {
        currentTaskGroup.tasks[currentTaskIndex]
    }
    
    private func approveCurrentTask() {
        moveToNextTask()
    }
    
    private func skipCurrentTask() {
        moveToNextTask()
    }
    
    private func moveToNextTask() {
        let currentGroup = currentTaskGroup
        
        if currentTaskIndex < currentGroup.tasks.count - 1 {
            // More tasks in current group
            currentTaskIndex += 1
            resetTaskFlow()
        } else {
            // Move to next group or finish
            if let nextGroupIndex = taskGroups.firstIndex(where: { $0.type == currentTaskType }),
               nextGroupIndex < taskGroups.count - 1 {
                // Move to next group
                currentTaskType = taskGroups[nextGroupIndex + 1].type
                currentTaskIndex = 0
                resetTaskFlow()
            } else {
                // All tasks completed - return to summary
                currentStep = .groupSummary
            }
        }
    }
    
    private func resetTaskFlow() {
        selectedContact = nil
        contactPhone = ""
        contactEmail = ""
        selectedTiming = .tomorrowAM
        
        // Check if task needs disambiguation
        if currentTask.isAmbiguous {
            currentStep = .contactDisambiguation
        } else {
            currentStep = .contactDetails
        }
    }
}

// MARK: - Data Models

struct TaskGroup {
    let type: TaskReviewFlow.TaskType
    let tasks: [ReviewTask]
}

struct ReviewTask: Identifiable {
    let id = UUID()
    let contactName: String
    let message: String
    let isAmbiguous: Bool
    let suggestedContacts: [Contact]
    
    init(contactName: String, message: String, isAmbiguous: Bool = false, suggestedContacts: [Contact] = []) {
        self.contactName = contactName
        self.message = message
        self.isAmbiguous = isAmbiguous
        self.suggestedContacts = suggestedContacts
    }
}


#Preview {
    TaskReviewFlow()
}
//
//  Task.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import Foundation

struct AppTask: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let captureId: UUID
    let type: TaskType
    let status: TaskStatus
    let contactId: UUID?
    let contactName: String?
    let message: String
    let originalTranscription: String // Voice capture context
    let scheduledFor: Date?
    let createdAt: Date
    let archivedAt: Date?
    let dismissedAt: Date?
    
    enum TaskType: String, Codable, CaseIterable {
        case followUpSMS = "follow_up_sms"
        case reminderCall = "reminder_call"
        case campaign = "campaign"
        case contactCRUD = "contact_crud"
        case emailSendReply = "email_send_reply"
        
        var displayName: String {
            switch self {
            case .followUpSMS: return "Follow-up SMS"
            case .reminderCall: return "Call Reminder"
            case .campaign: return "Campaign"
            case .contactCRUD: return "Contact Update"
            case .emailSendReply: return "Email"
            }
        }
        
        var color: String {
            switch self {
            case .followUpSMS: return "blue"
            case .reminderCall: return "orange"
            case .campaign: return "purple"
            case .contactCRUD: return "green"
            case .emailSendReply: return "indigo"
            }
        }
        
        var icon: String {
            switch self {
            case .followUpSMS: return "message.fill"
            case .reminderCall: return "phone.fill"
            case .campaign: return "megaphone.fill"
            case .contactCRUD: return "person.badge.plus.fill"
            case .emailSendReply: return "envelope.fill"
            }
        }
        
        var actionButtonText: String {
            switch self {
            case .followUpSMS: return "Send SMS"
            case .reminderCall: return "Set Reminder"
            case .campaign: return "Start Campaign"
            case .contactCRUD: return "Update Contact"
            case .emailSendReply: return "Send Email"
            }
        }
    }
    
    enum TaskStatus: String, Codable, CaseIterable {
        case pending
        case approved
        case sent
        case skipped
        case archived
        case dismissed
    }
    
    init(id: UUID = UUID(), userId: UUID, captureId: UUID, type: TaskType, status: TaskStatus = .pending, contactId: UUID? = nil, contactName: String? = nil, message: String, originalTranscription: String, scheduledFor: Date? = nil, createdAt: Date = Date(), archivedAt: Date? = nil, dismissedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.captureId = captureId
        self.type = type
        self.status = status
        self.contactId = contactId
        self.contactName = contactName
        self.message = message
        self.originalTranscription = originalTranscription
        self.scheduledFor = scheduledFor
        self.createdAt = createdAt
        self.archivedAt = archivedAt
        self.dismissedAt = dismissedAt
    }
}
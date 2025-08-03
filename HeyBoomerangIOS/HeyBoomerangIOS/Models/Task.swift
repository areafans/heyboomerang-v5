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
    
    // MARK: - Custom Codable Implementation
    
    enum CodingKeys: String, CodingKey {
        case id, userId, captureId, type, status, contactId, contactName, message, originalTranscription, scheduledFor, createdAt, archivedAt, dismissedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Convert string UUIDs to UUID objects - be more forgiving
        do {
            let idString = try container.decode(String.self, forKey: .id)
            self.id = UUID(uuidString: idString) ?? UUID()
        } catch {
            print("❌ Failed to decode id: \(error)")
            self.id = UUID()
        }
        
        do {
            let userIdString = try container.decode(String.self, forKey: .userId)
            self.userId = UUID(uuidString: userIdString) ?? UUID()
        } catch {
            print("❌ Failed to decode userId: \(error)")
            self.userId = UUID()
        }
        
        do {
            let captureIdString = try container.decode(String.self, forKey: .captureId)
            self.captureId = UUID(uuidString: captureIdString) ?? UUID()
        } catch {
            print("❌ Failed to decode captureId: \(error)")
            self.captureId = UUID()
        }
        
        do {
            self.type = try container.decode(TaskType.self, forKey: .type)
        } catch {
            print("❌ Failed to decode type: \(error)")
            self.type = .reminderCall // Default fallback
        }
        
        do {
            self.status = try container.decode(TaskStatus.self, forKey: .status)
        } catch {
            print("❌ Failed to decode status: \(error)")
            self.status = .pending // Default fallback
        }
        
        // Handle optional contactId
        do {
            if let contactIdString = try container.decodeIfPresent(String.self, forKey: .contactId) {
                self.contactId = UUID(uuidString: contactIdString)
            } else {
                self.contactId = nil
            }
        } catch {
            print("❌ Failed to decode contactId: \(error)")
            self.contactId = nil
        }
        
        do {
            self.contactName = try container.decodeIfPresent(String.self, forKey: .contactName)
        } catch {
            print("❌ Failed to decode contactName: \(error)")
            self.contactName = nil
        }
        
        do {
            self.message = try container.decode(String.self, forKey: .message)
        } catch {
            print("❌ Failed to decode message: \(error)")
            self.message = "Unknown message"
        }
        
        do {
            self.originalTranscription = try container.decode(String.self, forKey: .originalTranscription)
        } catch {
            print("❌ Failed to decode originalTranscription: \(error)")
            self.originalTranscription = ""
        }
        
        // Handle ISO8601 date strings with multiple formats - be forgiving
        let dateFormatter = ISO8601DateFormatter()
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS+00:00"
        fallbackFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        do {
            if let scheduledForString = try container.decodeIfPresent(String.self, forKey: .scheduledFor) {
                self.scheduledFor = dateFormatter.date(from: scheduledForString) ?? 
                                   fallbackFormatter.date(from: scheduledForString)
            } else {
                self.scheduledFor = nil
            }
        } catch {
            print("❌ Failed to decode scheduledFor: \(error)")
            self.scheduledFor = nil
        }
        
        do {
            let createdAtString = try container.decode(String.self, forKey: .createdAt)
            self.createdAt = dateFormatter.date(from: createdAtString) ?? 
                            fallbackFormatter.date(from: createdAtString) ?? 
                            Date()
        } catch {
            print("❌ Failed to decode createdAt: \(error)")
            self.createdAt = Date()
        }
        
        do {
            if let archivedAtString = try container.decodeIfPresent(String.self, forKey: .archivedAt) {
                self.archivedAt = dateFormatter.date(from: archivedAtString)
            } else {
                self.archivedAt = nil
            }
        } catch {
            print("❌ Failed to decode archivedAt: \(error)")
            self.archivedAt = nil
        }
        
        do {
            if let dismissedAtString = try container.decodeIfPresent(String.self, forKey: .dismissedAt) {
                self.dismissedAt = dateFormatter.date(from: dismissedAtString)
            } else {
                self.dismissedAt = nil
            }
        } catch {
            print("❌ Failed to decode dismissedAt: \(error)")
            self.dismissedAt = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Convert UUIDs to strings
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(userId.uuidString, forKey: .userId)
        try container.encode(captureId.uuidString, forKey: .captureId)
        try container.encode(type, forKey: .type)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(contactId?.uuidString, forKey: .contactId)
        try container.encodeIfPresent(contactName, forKey: .contactName)
        try container.encode(message, forKey: .message)
        try container.encode(originalTranscription, forKey: .originalTranscription)
        
        // Convert dates to ISO8601 strings
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        try container.encodeIfPresent(scheduledFor?.formatted(.iso8601), forKey: .scheduledFor)
        try container.encode(createdAt.formatted(.iso8601), forKey: .createdAt)
        try container.encodeIfPresent(archivedAt?.formatted(.iso8601), forKey: .archivedAt)
        try container.encodeIfPresent(dismissedAt?.formatted(.iso8601), forKey: .dismissedAt)
    }
}
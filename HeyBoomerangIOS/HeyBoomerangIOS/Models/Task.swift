//
//  Task.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import Foundation

struct Task: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let captureId: UUID
    let type: TaskType
    let status: TaskStatus
    let contactId: UUID?
    let contactName: String?
    let message: String
    let scheduledFor: Date?
    let createdAt: Date
    let archivedAt: Date?
    let dismissedAt: Date?
    
    enum TaskType: String, Codable, CaseIterable {
        case followUp = "follow_up"
        case reminder = "reminder"
        case campaign = "campaign"
        case note = "note"
    }
    
    enum TaskStatus: String, Codable, CaseIterable {
        case pending
        case approved
        case sent
        case skipped
        case archived
        case dismissed
    }
    
    init(id: UUID = UUID(), userId: UUID, captureId: UUID, type: TaskType, status: TaskStatus = .pending, contactId: UUID? = nil, contactName: String? = nil, message: String, scheduledFor: Date? = nil, createdAt: Date = Date(), archivedAt: Date? = nil, dismissedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.captureId = captureId
        self.type = type
        self.status = status
        self.contactId = contactId
        self.contactName = contactName
        self.message = message
        self.scheduledFor = scheduledFor
        self.createdAt = createdAt
        self.archivedAt = archivedAt
        self.dismissedAt = dismissedAt
    }
}
//
//  Contact.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import Foundation

struct Contact: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let name: String
    let email: String?
    let phone: String?
    let type: ContactType
    let notes: [String: String]?
    let lastContact: Date?
    let createdAt: Date
    
    enum ContactType: String, Codable, CaseIterable {
        case client
        case vendor
        case employee
    }
    
    init(id: UUID = UUID(), userId: UUID, name: String, email: String? = nil, phone: String? = nil, type: ContactType = .client, notes: [String: String]? = nil, lastContact: Date? = nil, createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.name = name
        self.email = email
        self.phone = phone
        self.type = type
        self.notes = notes
        self.lastContact = lastContact
        self.createdAt = createdAt
    }
}
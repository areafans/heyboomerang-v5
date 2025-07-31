//
//  Capture.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import Foundation

struct Capture: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let transcription: String
    let duration: TimeInterval?
    let createdAt: Date
    
    init(id: UUID = UUID(), userId: UUID, transcription: String, duration: TimeInterval? = nil, createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.transcription = transcription
        self.duration = duration
        self.createdAt = createdAt
    }
}
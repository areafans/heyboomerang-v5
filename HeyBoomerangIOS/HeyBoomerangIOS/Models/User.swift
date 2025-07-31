//
//  User.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let businessName: String?
    let businessType: String?
    let city: String?
    let state: String?
    let timezone: String?
    let subscriptionStatus: String
    let trialEndsAt: Date?
    let dailyCaptureCount: Int
    let dailyCaptureReset: Date?
    
    init(id: UUID = UUID(), email: String, businessName: String? = nil, businessType: String? = nil, city: String? = nil, state: String? = nil, timezone: String? = nil, subscriptionStatus: String = "trial", trialEndsAt: Date? = nil, dailyCaptureCount: Int = 0, dailyCaptureReset: Date? = nil) {
        self.id = id
        self.email = email
        self.businessName = businessName
        self.businessType = businessType
        self.city = city
        self.state = state
        self.timezone = timezone
        self.subscriptionStatus = subscriptionStatus
        self.trialEndsAt = trialEndsAt
        self.dailyCaptureCount = dailyCaptureCount
        self.dailyCaptureReset = dailyCaptureReset
    }
}
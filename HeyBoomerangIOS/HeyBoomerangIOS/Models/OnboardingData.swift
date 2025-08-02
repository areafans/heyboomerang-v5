//
//  OnboardingData.swift
//  HeyBoomerangIOS
//
//  Created by Claude on 8/2/25.
//

import Foundation

// Shared data model for onboarding process
class OnboardingData: ObservableObject {
    @Published var userName: String = ""
    @Published var businessName: String = ""
    @Published var businessDescription: String = ""
    @Published var email: String = ""
    @Published var accessToken: String = ""
    @Published var userId: String = ""
    
    // Helper to check if business info is complete
    var hasBusinessInfo: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !businessName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !businessDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Helper to check if authentication is complete
    var isAuthenticated: Bool {
        !accessToken.isEmpty && !userId.isEmpty
    }
    
    // Clear all data (for logout or reset)
    func reset() {
        userName = ""
        businessName = ""
        businessDescription = ""
        email = ""
        accessToken = ""
        userId = ""
    }
}
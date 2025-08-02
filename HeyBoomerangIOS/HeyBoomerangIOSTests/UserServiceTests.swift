//
//  UserServiceTests.swift
//  HeyBoomerangIOSTests
//
//  Created by Claude on 8/2/25.
//

import XCTest
@testable import HeyBoomerangIOS

final class UserServiceTests: XCTestCase {
    
    var userService: UserService!
    var mockAPIService: MockAPIService!
    var mockStorage: MockSecureStorage!
    
    override func setUp() async throws {
        mockAPIService = MockAPIService()
        mockStorage = MockSecureStorage()
        userService = UserService(apiService: mockAPIService, storage: mockStorage)
    }
    
    override func tearDown() async throws {
        userService = nil
        mockAPIService = nil
        mockStorage = nil
    }
    
    func testCreateUserProfileSuccess() async {
        // Given
        let email = "test@example.com"
        let businessName = "Test Business"
        
        // When
        let result = await userService.createUserProfile(
            email: email,
            businessName: businessName,
            businessType: "Technology",
            city: "San Francisco",
            state: "CA"
        )
        
        // Then
        switch result {
        case .success(let user):
            XCTAssertEqual(user.email, email)
            XCTAssertEqual(user.businessName, businessName)
            XCTAssertEqual(user.subscriptionStatus, "trial")
            XCTAssertNotNil(user.trialEndsAt)
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    func testCreateUserProfileInvalidEmail() async {
        // Given
        let invalidEmail = "invalid-email"
        
        // When
        let result = await userService.createUserProfile(
            email: invalidEmail,
            businessName: "Test Business",
            businessType: nil,
            city: nil,
            state: nil
        )
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected validation error for invalid email")
        case .failure(let error):
            if case .validation(.invalidEmail) = error {
                // Expected
            } else {
                XCTFail("Expected invalid email error, got: \(error)")
            }
        }
    }
    
    func testCreateUserProfileEmptyEmail() async {
        // Given
        let emptyEmail = ""
        
        // When
        let result = await userService.createUserProfile(
            email: emptyEmail,
            businessName: "Test Business",
            businessType: nil,
            city: nil,
            state: nil
        )
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected validation error for empty email")
        case .failure(let error):
            if case .validation(.emptyInput("Email")) = error {
                // Expected
            } else {
                XCTFail("Expected empty input error, got: \(error)")
            }
        }
    }
    
    func testIncrementDailyCaptureCount() async {
        // Given
        let user = createTestUser()
        await userService.updateUserProfile(user)
        
        // When
        let result = await userService.incrementDailyCaptureCount()
        
        // Then
        switch result {
        case .success(let count):
            XCTAssertEqual(count, 1)
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    func testCompleteOnboarding() async {
        // When
        let result = await userService.completeOnboarding()
        
        // Then
        switch result {
        case .success:
            XCTAssertTrue(userService.isOnboardingCompleted())
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    func testSignOut() async {
        // Given
        let user = createTestUser()
        await userService.updateUserProfile(user)
        
        // When
        let result = await userService.signOut()
        
        // Then
        switch result {
        case .success:
            XCTAssertNil(userService.currentUser)
            XCTAssertFalse(userService.isAuthenticated)
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestUser() -> User {
        return User(
            email: "test@example.com",
            businessName: "Test Business",
            businessType: "Technology",
            city: "San Francisco",
            state: "CA"
        )
    }
}

// MARK: - Mock Classes

class MockAPIService: APIServiceProtocol, ObservableObject {
    func submitCapture(transcription: String, duration: TimeInterval) async -> Result<CaptureResponse, AppError> {
        return .success(CaptureResponse(captureId: UUID(), suggestedTasks: nil, processingStatus: nil, createdAt: nil))
    }
    
    func getPendingTasks() async -> Result<TasksResponse, AppError> {
        return .success(TasksResponse(active: [], archived: [], stats: TaskStats(total: 0, needsInfo: 0), lastSyncedAt: nil))
    }
    
    func updateTask(id: UUID, status: Task.TaskStatus, contactId: UUID?, scheduledFor: Date?) async -> Result<Void, AppError> {
        return .success(())
    }
}

class MockSecureStorage: SecureStorageProtocol {
    private var storage: [String: Any] = [:]
    private var keychain: [String: Data] = [:]
    
    func store<T: Codable>(_ value: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(value)
        storage[key] = data
    }
    
    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) throws -> T {
        guard let data = storage[key] as? Data else {
            throw AppError.storage(.keyNotFound(key))
        }
        return try JSONDecoder().decode(type, from: data)
    }
    
    func delete(forKey key: String) throws {
        storage.removeValue(forKey: key)
    }
    
    func storeInKeychain(_ data: Data, forKey key: String) throws {
        keychain[key] = data
    }
    
    func retrieveFromKeychain(forKey key: String) throws -> Data {
        guard let data = keychain[key] else {
            throw AppError.storage(.keyNotFound(key))
        }
        return data
    }
    
    func deleteFromKeychain(forKey key: String) throws {
        keychain.removeValue(forKey: key)
    }
}
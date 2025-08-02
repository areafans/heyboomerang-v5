//
//  DependencyContainerTests.swift
//  HeyBoomerangIOSTests
//
//  Created by Claude on 8/2/25.
//

import XCTest
@testable import HeyBoomerangIOS

@MainActor
final class DependencyContainerTests: XCTestCase {
    
    var container: DependencyContainer!
    
    override func setUp() async throws {
        container = DependencyContainer.shared
    }
    
    func testResolveAppConfiguration() {
        let config = container.resolve(AppConfigurationProtocol.self)
        
        XCTAssertNotNil(config)
        XCTAssertTrue(config.maxRecordingDuration > 0)
        XCTAssertTrue(config.maxDailyCaptures > 0)
        XCTAssertFalse(config.apiBaseURL.isEmpty)
    }
    
    func testResolveSecureStorage() {
        let storage = container.resolve(SecureStorageProtocol.self)
        XCTAssertNotNil(storage)
    }
    
    func testResolveNetworkManager() {
        let networkManager = container.resolve(NetworkManagerProtocol.self)
        XCTAssertNotNil(networkManager)
    }
    
    func testResolveAPIService() {
        let apiService = container.resolve(APIServiceProtocol.self)
        XCTAssertNotNil(apiService)
    }
    
    func testResolveVoiceCaptureService() {
        let voiceService = container.resolve(VoiceCaptureServiceProtocol.self)
        XCTAssertNotNil(voiceService)
    }
    
    func testResolveTaskService() {
        let taskService = container.resolve(TaskServiceProtocol.self)
        XCTAssertNotNil(taskService)
    }
    
    func testResolveUserService() {
        let userService = container.resolve(UserServiceProtocol.self)
        XCTAssertNotNil(userService)
    }
    
    func testTryResolveNonExistentService() {
        let result = container.tryResolve(NonExistentProtocol.self)
        XCTAssertNil(result)
    }
}

// Test protocol for non-existent service
private protocol NonExistentProtocol {}
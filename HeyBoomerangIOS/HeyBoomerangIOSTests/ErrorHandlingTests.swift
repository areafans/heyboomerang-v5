//
//  ErrorHandlingTests.swift
//  HeyBoomerangIOSTests
//
//  Created by Claude on 8/2/25.
//

import XCTest
@testable import HeyBoomerangIOS

final class ErrorHandlingTests: XCTestCase {
    
    func testAppErrorEquality() {
        let error1 = AppError.network(.noConnection)
        let error2 = AppError.network(.noConnection)
        let error3 = AppError.network(.timeout)
        
        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }
    
    func testNetworkErrorDescriptions() {
        let noConnectionError = NetworkError.noConnection
        XCTAssertEqual(noConnectionError.errorDescription, "No internet connection")
        XCTAssertEqual(noConnectionError.failureReason, "Your device is not connected to the internet")
        XCTAssertEqual(noConnectionError.recoverySuggestion, "Check your internet connection and try again")
        
        let timeoutError = NetworkError.timeout
        XCTAssertEqual(timeoutError.errorDescription, "Request timed out")
        XCTAssertEqual(timeoutError.failureReason, "The server took too long to respond")
        XCTAssertEqual(timeoutError.recoverySuggestion, "Check your connection and try again")
    }
    
    func testAPIErrorDescriptions() {
        let invalidResponseError = APIError.invalidResponse
        XCTAssertEqual(invalidResponseError.errorDescription, "Invalid server response")
        XCTAssertNotNil(invalidResponseError.failureReason)
        XCTAssertNotNil(invalidResponseError.recoverySuggestion)
        
        let unauthorizedError = APIError.unauthorized
        XCTAssertEqual(unauthorizedError.errorDescription, "Authentication required")
        XCTAssertEqual(unauthorizedError.recoverySuggestion, "Please sign in again")
    }
    
    func testVoiceCaptureErrorDescriptions() {
        let permissionError = VoiceCaptureError.permissionDenied
        XCTAssertEqual(permissionError.errorDescription, "Microphone access denied")
        XCTAssertTrue(permissionError.recoverySuggestion?.contains("Settings") == true)
        
        let unavailableError = VoiceCaptureError.unavailable
        XCTAssertEqual(unavailableError.errorDescription, "Voice capture unavailable")
        XCTAssertNotNil(unavailableError.recoverySuggestion)
    }
    
    func testValidationErrorDescriptions() {
        let emptyInputError = ValidationError.emptyInput("Email")
        XCTAssertEqual(emptyInputError.errorDescription, "Email cannot be empty")
        
        let invalidEmailError = ValidationError.invalidEmail
        XCTAssertEqual(invalidEmailError.errorDescription, "Invalid email address")
        
        let textTooLongError = ValidationError.textTooLong("Message", 100)
        XCTAssertEqual(textTooLongError.errorDescription, "Message cannot exceed 100 characters")
    }
    
    func testStorageErrorDescriptions() {
        let keyNotFoundError = StorageError.keyNotFound("test_key")
        XCTAssertEqual(keyNotFoundError.errorDescription, "Data not found: test_key")
        
        let saveFailedError = StorageError.saveFailed("disk full")
        XCTAssertEqual(saveFailedError.errorDescription, "Save failed: disk full")
        
        let keychainError = StorageError.keychainError(-25300)
        XCTAssertEqual(keychainError.errorDescription, "Keychain error: -25300")
    }
}
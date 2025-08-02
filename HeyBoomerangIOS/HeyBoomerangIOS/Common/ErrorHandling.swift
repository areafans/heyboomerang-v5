//
//  ErrorHandling.swift
//  HeyBoomerangIOS
//
//  Created by Claude on 8/2/25.
//

import Foundation
import OSLog

// MARK: - Comprehensive Error System

/// Application-wide error types with proper localization support
enum AppError: Error, LocalizedError, Equatable {
    case network(NetworkError)
    case api(APIError)
    case voiceCapture(VoiceCaptureError)
    case storage(StorageError)
    case validation(ValidationError)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .network(let error):
            return error.localizedDescription
        case .api(let error):
            return error.localizedDescription
        case .voiceCapture(let error):
            return error.localizedDescription
        case .storage(let error):
            return error.localizedDescription
        case .validation(let error):
            return error.localizedDescription
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .network(let error):
            return error.failureReason
        case .api(let error):
            return error.failureReason
        case .voiceCapture(let error):
            return error.failureReason
        case .storage(let error):
            return error.failureReason
        case .validation(let error):
            return error.failureReason
        case .unknown:
            return "An unexpected error occurred"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .network(let error):
            return error.recoverySuggestion
        case .api(let error):
            return error.recoverySuggestion
        case .voiceCapture(let error):
            return error.recoverySuggestion
        case .storage(let error):
            return error.recoverySuggestion
        case .validation(let error):
            return error.recoverySuggestion
        case .unknown:
            return "Please try again or contact support if the problem persists"
        }
    }
}

// MARK: - Specific Error Types

enum NetworkError: Error, LocalizedError, Equatable {
    case noConnection
    case timeout
    case invalidURL(String)
    case serverError(Int)
    case rateLimited
    
    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .serverError(let code):
            return "Server error (\(code))"
        case .rateLimited:
            return "Too many requests"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .noConnection:
            return "Your device is not connected to the internet"
        case .timeout:
            return "The server took too long to respond"
        case .invalidURL:
            return "The request URL is malformed"
        case .serverError(let code):
            return "The server returned an error with status code \(code)"
        case .rateLimited:
            return "You have made too many requests in a short time"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noConnection:
            return "Check your internet connection and try again"
        case .timeout:
            return "Check your connection and try again"
        case .invalidURL:
            return "Please contact support"
        case .serverError:
            return "Please try again later"
        case .rateLimited:
            return "Please wait a moment and try again"
        }
    }
}

enum APIError: Error, LocalizedError, Equatable {
    case invalidResponse
    case decodingFailed(String)
    case unauthorized
    case forbidden
    case notFound
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .decodingFailed(let details):
            return "Failed to process server response: \(details)"
        case .unauthorized:
            return "Authentication required"
        case .forbidden:
            return "Access denied"
        case .notFound:
            return "Resource not found"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .invalidResponse:
            return "The server response was not in the expected format"
        case .decodingFailed:
            return "The app couldn't understand the server's response"
        case .unauthorized:
            return "Your session has expired or is invalid"
        case .forbidden:
            return "You don't have permission to access this resource"
        case .notFound:
            return "The requested resource could not be found"
        case .serverError:
            return "The server encountered an internal error"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidResponse:
            return "Please try again or contact support"
        case .decodingFailed:
            return "Please update the app or contact support"
        case .unauthorized:
            return "Please sign in again"
        case .forbidden:
            return "Contact support if you believe this is an error"
        case .notFound:
            return "Please try again or check your request"
        case .serverError:
            return "Please try again later"
        }
    }
}

enum VoiceCaptureError: Error, LocalizedError, Equatable {
    case permissionDenied
    case unavailable
    case recordingFailed(String)
    case transcriptionFailed
    case audioTooShort
    case audioTooLong
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Microphone access denied"
        case .unavailable:
            return "Voice capture unavailable"
        case .recordingFailed(let reason):
            return "Recording failed: \(reason)"
        case .transcriptionFailed:
            return "Speech recognition failed"
        case .audioTooShort:
            return "Recording too short"
        case .audioTooLong:
            return "Recording too long"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .permissionDenied:
            return "The app needs microphone access to capture voice notes"
        case .unavailable:
            return "Voice capture is not available on this device"
        case .recordingFailed:
            return "An error occurred while recording audio"
        case .transcriptionFailed:
            return "The system couldn't convert speech to text"
        case .audioTooShort:
            return "The recording was shorter than the minimum required duration"
        case .audioTooLong:
            return "The recording exceeded the maximum allowed duration"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return "Go to Settings > Privacy & Security > Microphone and enable access for this app"
        case .unavailable:
            return "Try restarting the app or your device"
        case .recordingFailed:
            return "Check your microphone and try again"
        case .transcriptionFailed:
            return "Speak more clearly and try again"
        case .audioTooShort:
            return "Hold the button longer and speak clearly"
        case .audioTooLong:
            return "Keep recordings under 10 seconds for best results"
        }
    }
}

enum StorageError: Error, LocalizedError, Equatable {
    case keyNotFound(String)
    case saveFailed(String)
    case loadFailed(String)
    case keychainError(OSStatus)
    case insufficientStorage
    
    var errorDescription: String? {
        switch self {
        case .keyNotFound(let key):
            return "Data not found: \(key)"
        case .saveFailed(let details):
            return "Save failed: \(details)"
        case .loadFailed(let details):
            return "Load failed: \(details)"
        case .keychainError(let status):
            return "Keychain error: \(status)"
        case .insufficientStorage:
            return "Insufficient storage space"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .keyNotFound:
            return "The requested data could not be found"
        case .saveFailed:
            return "The data could not be saved"
        case .loadFailed:
            return "The data could not be loaded"
        case .keychainError:
            return "An error occurred accessing secure storage"
        case .insufficientStorage:
            return "Your device is running low on storage space"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .keyNotFound:
            return "The data may not exist or may have been removed"
        case .saveFailed:
            return "Free up storage space and try again"
        case .loadFailed:
            return "Try restarting the app"
        case .keychainError:
            return "Try restarting the app or your device"
        case .insufficientStorage:
            return "Free up storage space on your device"
        }
    }
}

enum ValidationError: Error, LocalizedError, Equatable {
    case emptyInput(String)
    case invalidEmail
    case invalidPhoneNumber
    case textTooLong(String, Int)
    case textTooShort(String, Int)
    case invalidFormat(String)
    
    var errorDescription: String? {
        switch self {
        case .emptyInput(let field):
            return "\(field) cannot be empty"
        case .invalidEmail:
            return "Invalid email address"
        case .invalidPhoneNumber:
            return "Invalid phone number"
        case .textTooLong(let field, let maxLength):
            return "\(field) cannot exceed \(maxLength) characters"
        case .textTooShort(let field, let minLength):
            return "\(field) must be at least \(minLength) characters"
        case .invalidFormat(let field):
            return "Invalid \(field) format"
        }
    }
    
    var failureReason: String? {
        return "The input data doesn't meet the required format"
    }
    
    var recoverySuggestion: String? {
        return "Please check your input and try again"
    }
}

// MARK: - Logging System

/// Centralized logging system using OSLog for production-ready logging
actor Logger {
    static let shared = Logger()
    
    private let logger = os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "HeyBoomerangIOS", category: "main")
    
    private init() {}
    
    func debug(_ message: String, category: LogCategory = .general) {
        #if DEBUG
        logger.debug("[\(category.rawValue)] \(message)")
        #endif
    }
    
    func info(_ message: String, category: LogCategory = .general) {
        logger.info("[\(category.rawValue)] \(message)")
    }
    
    func warning(_ message: String, category: LogCategory = .general) {
        logger.warning("[\(category.rawValue)] \(message)")
    }
    
    func error(_ message: String, error: Error? = nil, category: LogCategory = .general) {
        if let error = error {
            logger.error("[\(category.rawValue)] \(message): \(error.localizedDescription)")
        } else {
            logger.error("[\(category.rawValue)] \(message)")
        }
    }
    
    func fault(_ message: String, error: Error? = nil, category: LogCategory = .general) {
        if let error = error {
            logger.fault("[\(category.rawValue)] \(message): \(error.localizedDescription)")
        } else {
            logger.fault("[\(category.rawValue)] \(message)")
        }
    }
}

enum LogCategory: String {
    case general = "General"
    case network = "Network"
    case voiceCapture = "VoiceCapture"
    case ui = "UI"
    case storage = "Storage"
    case api = "API"
    case security = "Security"
}

// MARK: - Result Extensions

extension Result {
    /// Logs the error if the result is a failure
    func logError(message: String, category: LogCategory = .general) -> Result<Success, Failure> {
        if case .failure(let error) = self {
            Task {
                await Logger.shared.error(message, error: error, category: category)
            }
        }
        return self
    }
}
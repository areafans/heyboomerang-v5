//
//  APIService.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//  Refactored by Claude on 8/2/25.
//

import Foundation

// MARK: - Modern API Service Implementation

final class APIService: APIServiceProtocol, ObservableObject {
    private let networkManager: NetworkManagerProtocol
    private let configuration: AppConfigurationProtocol
    private let authService: SupabaseAuthService
    
    init(networkManager: NetworkManagerProtocol, configuration: AppConfigurationProtocol, authService: SupabaseAuthService = SupabaseAuthService.shared) {
        self.networkManager = networkManager
        self.configuration = configuration
        self.authService = authService
    }
    
    // MARK: - Capture API
    
    func submitCapture(transcription: String, duration: TimeInterval) async -> Result<CaptureResponse, AppError> {
        print("🌐 API: Submitting capture to backend...")
        print("🔑 API: Auth token available: \(authService.accessToken != nil)")
        await Logger.shared.info("Submitting capture with transcription length: \(transcription.count)", category: .api)
        
        guard let url = URL.apiURL(path: "capture", configuration: configuration) else {
            await Logger.shared.error("Failed to create capture URL", category: .api)
            return .failure(.network(.invalidURL("capture endpoint")))
        }
        
        let requestBody = CaptureRequest(transcription: transcription, duration: duration)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.keyEncodingStrategy = .convertToSnakeCase
            
            let bodyData = try encoder.encode(requestBody)
            let request = URLRequest.apiRequest(url: url, method: .POST, body: bodyData, authToken: authService.accessToken)
            
            return await networkManager.performRequest(request, responseType: CaptureResponse.self)
                .logError(message: "Failed to submit capture", category: .api)
            
        } catch {
            await Logger.shared.error("Failed to encode capture request", error: error, category: .api)
            return .failure(.api(.decodingFailed("Failed to encode request: \(error.localizedDescription)")))
        }
    }
    
    // MARK: - Tasks API
    
    func getPendingTasks() async -> Result<TasksResponse, AppError> {
        print("🌐 API: Fetching tasks from backend...")
        print("🔑 API: Auth token available: \(authService.accessToken != nil)")
        print("🎯 API: Backend URL: \(configuration.apiBaseURL)")
        await Logger.shared.info("Fetching pending tasks", category: .api)
        
        guard let url = URL.apiURL(path: "tasks/pending", configuration: configuration) else {
            await Logger.shared.error("Failed to create tasks URL", category: .api)
            return .failure(.network(.invalidURL("tasks/pending endpoint")))
        }
        
        let request = URLRequest.apiRequest(url: url, method: .GET, authToken: authService.accessToken)
        
        return await networkManager.performRequest(request, responseType: TasksResponse.self)
            .logError(message: "Failed to fetch pending tasks", category: .api)
    }
    
    func updateTask(id: UUID, status: AppTask.TaskStatus, contactId: UUID?, scheduledFor: Date?) async -> Result<Void, AppError> {
        await Logger.shared.info("Updating task \(id) to status: \(status)", category: .api)
        
        guard let url = URL.apiURL(path: "tasks/\(id)", configuration: configuration) else {
            await Logger.shared.error("Failed to create task update URL for task: \(id)", category: .api)
            return .failure(.network(.invalidURL("tasks/\(id) endpoint")))
        }
        
        let requestBody = UpdateTaskRequest(status: status.rawValue, contactId: contactId, scheduledFor: scheduledFor)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.keyEncodingStrategy = .convertToSnakeCase
            
            let bodyData = try encoder.encode(requestBody)
            let request = URLRequest.apiRequest(url: url, method: .PUT, body: bodyData, authToken: authService.accessToken)
            
            return await networkManager.performRequest(request)
                .logError(message: "Failed to update task \(id)", category: .api)
            
        } catch {
            await Logger.shared.error("Failed to encode task update request", error: error, category: .api)
            return .failure(.api(.decodingFailed("Failed to encode request: \(error.localizedDescription)")))
        }
    }
}

// MARK: - Request/Response Models

struct CaptureRequest: Codable {
    let transcription: String
    let duration: TimeInterval
    
    // Input validation
    var isValid: Bool {
        !transcription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        duration > 0 && duration <= 60 // Max 60 seconds
    }
}

struct CaptureResponse: Codable {
    let captureId: UUID
    let suggestedTasks: [AppTask]?
    let processingStatus: String?
    let createdAt: Date?
}

struct TasksResponse: Codable {
    let active: [AppTask]
    let archived: [AppTask]
    let stats: TaskStats
    let lastSyncedAt: Date?
}

struct TaskStats: Codable {
    let total: Int
    let needsInfo: Int
    let completedToday: Int?
    let averageResponseTime: TimeInterval?
}

struct UpdateTaskRequest: Codable {
    let status: String
    let contactId: UUID?
    let scheduledFor: Date?
    let updatedAt: Date
    
    init(status: String, contactId: UUID? = nil, scheduledFor: Date? = nil) {
        self.status = status
        self.contactId = contactId
        self.scheduledFor = scheduledFor
        self.updatedAt = Date()
    }
}
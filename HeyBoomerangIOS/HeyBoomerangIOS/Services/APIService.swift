//
//  APIService.swift
//  HeyBoomerangIOS
//
//  Created by Jason Clark on 7/31/25.
//

import Foundation

class APIService: ObservableObject {
    static let shared = APIService()
    
    private let baseURL = "https://your-vercel-app.vercel.app/api"
    
    private init() {}
    
    // MARK: - Capture API
    
    func submitCapture(transcription: String, duration: TimeInterval) async throws -> CaptureResponse {
        let url = URL(string: "\(baseURL)/capture")!
        
        let request = CaptureRequest(transcription: transcription, duration: duration)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(CaptureResponse.self, from: data)
    }
    
    // MARK: - Tasks API
    
    func getPendingTasks() async throws -> TasksResponse {
        let url = URL(string: "\(baseURL)/tasks/pending")!
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(TasksResponse.self, from: data)
    }
    
    func updateTask(id: UUID, status: Task.TaskStatus, contactId: UUID? = nil, scheduledFor: Date? = nil) async throws {
        let url = URL(string: "\(baseURL)/tasks/\(id)")!
        
        let request = UpdateTaskRequest(status: status.rawValue, contactId: contactId, scheduledFor: scheduledFor)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
    }
}

// MARK: - Request/Response Models

struct CaptureRequest: Codable {
    let transcription: String
    let duration: TimeInterval
}

struct CaptureResponse: Codable {
    let captureId: UUID
    let suggestedTasks: [Task]?
}

struct TasksResponse: Codable {
    let active: [Task]
    let archived: [Task]
    let stats: TaskStats
}

struct TaskStats: Codable {
    let total: Int
    let needsInfo: Int
}

struct UpdateTaskRequest: Codable {
    let status: String
    let contactId: UUID?
    let scheduledFor: Date?
}

enum APIError: Error, LocalizedError {
    case invalidResponse
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError:
            return "Network error occurred"
        }
    }
}
//
//  DependencyContainer.swift
//  HeyBoomerangIOS
//
//  Created by Claude on 8/2/25.
//

import Foundation

// MARK: - Dependency Injection Container

/// Simple dependency injection container for managing app services
@MainActor
final class DependencyContainer: ObservableObject {
    static let shared = DependencyContainer()
    
    // Direct service references - concrete types for simplicity
    private var _appConfiguration: AppConfiguration!
    private var _secureStorage: SecureStorage!
    private var _networkManager: NetworkManager!
    private var _apiService: APIService!
    private var _voiceCaptureService: VoiceCaptureService!
    private var _taskService: TaskService!
    private var _userService: UserService!
    
    private init() {
        setupServices()
    }
    
    // MARK: - Service Accessors
    
    var appConfiguration: AppConfiguration { _appConfiguration }
    var secureStorage: SecureStorage { _secureStorage }
    var networkManager: NetworkManager { _networkManager }
    var apiService: APIService { _apiService }
    var voiceCaptureService: VoiceCaptureService { _voiceCaptureService }
    var taskService: TaskService { _taskService }
    var userService: UserService { _userService }
    
    private func setupServices() {
        // Create core services
        _appConfiguration = AppConfiguration()
        _secureStorage = SecureStorage()
        
        // Create network services
        _networkManager = NetworkManager(configuration: _appConfiguration)
        _apiService = APIService(networkManager: _networkManager, configuration: _appConfiguration)
        
        // Create voice capture service
        _voiceCaptureService = VoiceCaptureService(configuration: _appConfiguration)
        
        // Create business services
        _taskService = TaskService(apiService: _apiService, storage: _secureStorage)
        _userService = UserService(apiService: _apiService, storage: _secureStorage)
    }
}

// MARK: - Service Protocols

protocol AppConfigurationProtocol {
    var apiBaseURL: String { get }
    var environment: AppEnvironment { get }
    var isDebugMode: Bool { get }
    var maxRecordingDuration: TimeInterval { get }
    var maxDailyCaptures: Int { get }
    var requestTimeout: TimeInterval { get }
}

protocol SecureStorageProtocol {
    func store<T: Codable>(_ value: T, forKey key: String) throws
    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) throws -> T
    func delete(forKey key: String) throws
    func storeInKeychain(_ data: Data, forKey key: String) throws
    func retrieveFromKeychain(forKey key: String) throws -> Data
    func deleteFromKeychain(forKey key: String) throws
}

protocol NetworkManagerProtocol {
    func performRequest<T: Codable>(_ request: URLRequest, responseType: T.Type) async -> Result<T, AppError>
    func performRequest(_ request: URLRequest) async -> Result<Void, AppError>
}

protocol APIServiceProtocol {
    func submitCapture(transcription: String, duration: TimeInterval) async -> Result<CaptureResponse, AppError>
    func getPendingTasks() async -> Result<TasksResponse, AppError>
    func updateTask(id: UUID, status: AppTask.TaskStatus, contactId: UUID?, scheduledFor: Date?) async -> Result<Void, AppError>
}

protocol VoiceCaptureServiceProtocol: ObservableObject {
    var isRecording: Bool { get }
    var transcription: String { get }
    var currentError: AppError? { get }
    
    func startRecording() async -> Result<Void, AppError>
    func stopRecording() async -> Result<String, AppError>
    func requestPermissions() async -> Result<Bool, AppError>
}

protocol TaskServiceProtocol {
    func loadPendingTasks() async -> Result<[AppTask], AppError>
    func approveTask(_ task: AppTask) async -> Result<Void, AppError>
    func skipTask(_ task: AppTask) async -> Result<Void, AppError>
    func updateTaskStatus(_ taskId: UUID, status: AppTask.TaskStatus) async -> Result<Void, AppError>
}

protocol UserServiceProtocol: ObservableObject {
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }
    var isLoading: Bool { get }
    var lastError: AppError? { get }
    
    func getCurrentUser() async -> Result<User?, AppError>
    func updateUserProfile(_ user: User) async -> Result<User, AppError>
    func signOut() async -> Result<Void, AppError>
    func isOnboardingCompleted() -> Bool
    func completeOnboarding() async -> Result<Void, AppError>
}

// MARK: - App Configuration

enum AppEnvironment: String, CaseIterable {
    case development = "development"
    case staging = "staging"
    case production = "production"
    
    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #elseif STAGING
        return .staging
        #else
        return .production
        #endif
    }
}

final class AppConfiguration: AppConfigurationProtocol {
    let environment = AppEnvironment.current
    
    var apiBaseURL: String {
        switch environment {
        case .development:
            return "https://dev-api.heyboomerang.com/api"
        case .staging:
            return "https://staging-api.heyboomerang.com/api"
        case .production:
            return "https://api.heyboomerang.com/api"
        }
    }
    
    var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    let maxRecordingDuration: TimeInterval = 10.0
    let maxDailyCaptures: Int = 32
    let requestTimeout: TimeInterval = 30.0
}


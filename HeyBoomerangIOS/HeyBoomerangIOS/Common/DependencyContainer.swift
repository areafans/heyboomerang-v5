//
//  DependencyContainer.swift
//  HeyBoomerangIOS
//
//  Created by Claude on 8/2/25.
//

import Foundation

// MARK: - Dependency Injection Container

/// Thread-safe dependency injection container for managing app services
@MainActor
final class DependencyContainer: ObservableObject {
    static let shared = DependencyContainer()
    
    private var services: [String: Any] = [:]
    private let queue = DispatchQueue(label: "com.heyboomerang.dependency-container", attributes: .concurrent)
    
    private init() {
        registerDefaultServices()
    }
    
    /// Register a service with the container
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        services[key] = factory()
    }
    
    /// Register a singleton service with the container
    func registerSingleton<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        services[key] = instance
    }
    
    /// Resolve a service from the container
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard let service = services[key] as? T else {
            fatalError("Service of type \(type) not registered")
        }
        return service
    }
    
    /// Try to resolve a service from the container (returns nil if not found)
    func tryResolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        return services[key] as? T
    }
    
    private func registerDefaultServices() {
        // Register core services
        registerSingleton(AppConfigurationProtocol.self, instance: AppConfiguration())
        registerSingleton(SecureStorageProtocol.self, instance: SecureStorage())
        
        // Register network services
        let config = resolve(AppConfigurationProtocol.self)
        let storage = resolve(SecureStorageProtocol.self)
        
        let networkManager = NetworkManager(configuration: config)
        registerSingleton(any NetworkManagerProtocol.self, instance: networkManager)
        
        let apiService = APIService(networkManager: networkManager, configuration: config)
        registerSingleton(any APIServiceProtocol.self, instance: apiService)
        
        // Register voice capture service
        let voiceService = VoiceCaptureService(configuration: config)
        registerSingleton(any VoiceCaptureServiceProtocol.self, instance: voiceService)
        
        // Register business services
        let taskService = TaskService(apiService: apiService, storage: storage)
        registerSingleton(any TaskServiceProtocol.self, instance: taskService)
        
        let userService = UserService(apiService: apiService, storage: storage)
        registerSingleton(any UserServiceProtocol.self, instance: userService)
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
    func updateTask(id: UUID, status: Task.TaskStatus, contactId: UUID?, scheduledFor: Date?) async -> Result<Void, AppError>
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
    func loadPendingTasks() async -> Result<[Task], AppError>
    func approveTask(_ task: Task) async -> Result<Void, AppError>
    func skipTask(_ task: Task) async -> Result<Void, AppError>
    func updateTaskStatus(_ taskId: UUID, status: Task.TaskStatus) async -> Result<Void, AppError>
}

protocol UserServiceProtocol {
    func getCurrentUser() async -> Result<User?, AppError>
    func updateUserProfile(_ user: User) async -> Result<User, AppError>
    func signOut() async -> Result<Void, AppError>
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

// MARK: - Property Wrapper for Dependency Injection

@propertyWrapper
struct Injected<T> {
    private let type: T.Type
    
    init(_ type: T.Type) {
        self.type = type
    }
    
    var wrappedValue: T {
        DependencyContainer.shared.resolve(type)
    }
}
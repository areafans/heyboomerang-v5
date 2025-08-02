//
//  TaskService.swift
//  HeyBoomerangIOS
//
//  Created by Claude on 8/2/25.
//

import Foundation

// MARK: - Task Business Logic Service

final class TaskService: TaskServiceProtocol, ObservableObject {
    private let apiService: APIServiceProtocol
    private let storage: SecureStorageProtocol
    
    @Published var pendingTasks: [Task] = []
    @Published var isLoading = false
    @Published var lastError: AppError?
    
    init(apiService: APIServiceProtocol, storage: SecureStorageProtocol) {
        self.apiService = apiService
        self.storage = storage
        
        // Load cached tasks on initialization
        Task {
            await loadCachedTasks()
        }
    }
    
    // MARK: - Public Interface
    
    func loadPendingTasks() async -> Result<[Task], AppError> {
        await Logger.shared.info("Loading pending tasks", category: .api)
        
        await MainActor.run {
            isLoading = true
            lastError = nil
        }
        
        let result = await apiService.getPendingTasks()
        
        await MainActor.run {
            isLoading = false
        }
        
        switch result {
        case .success(let response):
            let activeTasks = response.active
            
            await MainActor.run {
                pendingTasks = activeTasks
            }
            
            // Cache tasks for offline access
            await cacheTasks(activeTasks)
            
            await Logger.shared.info("Loaded \(activeTasks.count) pending tasks", category: .api)
            return .success(activeTasks)
            
        case .failure(let error):
            await MainActor.run {
                lastError = error
            }
            
            await Logger.shared.error("Failed to load pending tasks", error: error, category: .api)
            
            // Try to return cached tasks as fallback
            if let cachedTasks = await loadCachedTasks() {
                await Logger.shared.info("Returning \(cachedTasks.count) cached tasks as fallback", category: .api)
                return .success(cachedTasks)
            }
            
            return .failure(error)
        }
    }
    
    func approveTask(_ task: Task) async -> Result<Void, AppError> {
        await Logger.shared.info("Approving task: \(task.id)", category: .api)
        
        let result = await apiService.updateTask(
            id: task.id,
            status: .approved,
            contactId: task.contactId,
            scheduledFor: task.scheduledFor
        )
        
        switch result {
        case .success:
            await removeTaskFromPending(task.id)
            await Logger.shared.info("Successfully approved task: \(task.id)", category: .api)
            return .success(())
            
        case .failure(let error):
            await MainActor.run {
                lastError = error
            }
            await Logger.shared.error("Failed to approve task: \(task.id)", error: error, category: .api)
            return .failure(error)
        }
    }
    
    func skipTask(_ task: Task) async -> Result<Void, AppError> {
        await Logger.shared.info("Skipping task: \(task.id)", category: .api)
        
        let result = await apiService.updateTask(
            id: task.id,
            status: .skipped,
            contactId: nil,
            scheduledFor: nil
        )
        
        switch result {
        case .success:
            await removeTaskFromPending(task.id)
            await Logger.shared.info("Successfully skipped task: \(task.id)", category: .api)
            return .success(())
            
        case .failure(let error):
            await MainActor.run {
                lastError = error
            }
            await Logger.shared.error("Failed to skip task: \(task.id)", error: error, category: .api)
            return .failure(error)
        }
    }
    
    func updateTaskStatus(_ taskId: UUID, status: Task.TaskStatus) async -> Result<Void, AppError> {
        await Logger.shared.info("Updating task \(taskId) status to: \(status)", category: .api)
        
        let result = await apiService.updateTask(id: taskId, status: status, contactId: nil, scheduledFor: nil)
        
        switch result {
        case .success:
            if status == .approved || status == .skipped {
                await removeTaskFromPending(taskId)
            }
            return .success(())
            
        case .failure(let error):
            await MainActor.run {
                lastError = error
            }
            return .failure(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func removeTaskFromPending(_ taskId: UUID) async {
        await MainActor.run {
            pendingTasks.removeAll { $0.id == taskId }
        }
        
        // Update cache
        await cacheTasks(pendingTasks)
    }
    
    private func cacheTasks(_ tasks: [Task]) async {
        do {
            try storage.store(tasks, forKey: StorageKey.cachedTasks)
            await Logger.shared.debug("Cached \(tasks.count) tasks", category: .storage)
        } catch {
            await Logger.shared.error("Failed to cache tasks", error: error, category: .storage)
        }
    }
    
    @discardableResult
    private func loadCachedTasks() async -> [Task]? {
        do {
            let cachedTasks = try storage.retrieve([Task].self, forKey: StorageKey.cachedTasks)
            await MainActor.run {
                pendingTasks = cachedTasks
            }
            await Logger.shared.debug("Loaded \(cachedTasks.count) cached tasks", category: .storage)
            return cachedTasks
        } catch {
            await Logger.shared.debug("No cached tasks found", category: .storage)
            return nil
        }
    }
}

// MARK: - Storage Key Extension

extension StorageKey {
    static let cachedTasks = "cached_tasks"
}
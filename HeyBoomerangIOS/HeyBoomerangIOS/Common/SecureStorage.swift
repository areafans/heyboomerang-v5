//
//  SecureStorage.swift
//  HeyBoomerangIOS
//
//  Created by Claude on 8/2/25.
//

import Foundation
import Security

// MARK: - Secure Storage Implementation

final class SecureStorage: SecureStorageProtocol {
    private let userDefaults = UserDefaults.standard
    private let keychain = KeychainManager()
    
    // MARK: - UserDefaults Storage (for non-sensitive data)
    
    func store<T: Codable>(_ value: T, forKey key: String) throws {
        do {
            let data = try JSONEncoder().encode(value)
            userDefaults.set(data, forKey: key)
            
            Logger.shared.debug("Stored value for key: \(key)", category: .storage)
        } catch {
            Task {
                Logger.shared.error("Failed to store value for key: \(key)", error: error, category: .storage)
            }
            throw AppError.storage(.saveFailed("Failed to encode value: \(error.localizedDescription)"))
        }
    }
    
    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) throws -> T {
        guard let data = userDefaults.data(forKey: key) else {
            Task {
                Logger.shared.warning("No data found for key: \(key)", category: .storage)
            }
            throw AppError.storage(.keyNotFound(key))
        }
        
        do {
            let value = try JSONDecoder().decode(type, from: data)
            Task {
                Logger.shared.debug("Retrieved value for key: \(key)", category: .storage)
            }
            return value
        } catch {
            Task {
                Logger.shared.error("Failed to retrieve value for key: \(key)", error: error, category: .storage)
            }
            throw AppError.storage(.loadFailed("Failed to decode value: \(error.localizedDescription)"))
        }
    }
    
    func delete(forKey key: String) throws {
        userDefaults.removeObject(forKey: key)
        Task {
            Logger.shared.debug("Deleted value for key: \(key)", category: .storage)
        }
    }
    
    // MARK: - Keychain Storage (for sensitive data)
    
    func storeInKeychain(_ data: Data, forKey key: String) throws {
        do {
            try keychain.store(data, forKey: key)
            Task {
                Logger.shared.debug("Stored sensitive data in keychain for key: \(key)", category: .security)
            }
        } catch {
            Task {
                Logger.shared.error("Failed to store in keychain for key: \(key)", error: error, category: .security)
            }
            throw error
        }
    }
    
    func retrieveFromKeychain(forKey key: String) throws -> Data {
        do {
            let data = try keychain.retrieve(forKey: key)
            Task {
                Logger.shared.debug("Retrieved sensitive data from keychain for key: \(key)", category: .security)
            }
            return data
        } catch {
            Task {
                Logger.shared.error("Failed to retrieve from keychain for key: \(key)", error: error, category: .security)
            }
            throw error
        }
    }
    
    func deleteFromKeychain(forKey key: String) throws {
        do {
            try keychain.delete(forKey: key)
            Task {
                Logger.shared.debug("Deleted sensitive data from keychain for key: \(key)", category: .security)
            }
        } catch {
            Task {
                Logger.shared.error("Failed to delete from keychain for key: \(key)", error: error, category: .security)
            }
            throw error
        }
    }
}

// MARK: - Keychain Manager

private final class KeychainManager {
    private let service = Bundle.main.bundleIdentifier ?? "com.heyboomerang.ios"
    
    func store(_ data: Data, forKey key: String) throws {
        // First, try to delete any existing item
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Add the new item
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw AppError.storage(.keychainError(status))
        }
    }
    
    func retrieve(forKey key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw AppError.storage(.keyNotFound(key))
            }
            throw AppError.storage(.keychainError(status))
        }
        
        guard let data = result as? Data else {
            throw AppError.storage(.loadFailed("Invalid data format in keychain"))
        }
        
        return data
    }
    
    func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        // Success or item not found are both acceptable outcomes
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AppError.storage(.keychainError(status))
        }
    }
}

// MARK: - Storage Keys

enum StorageKey {
    static let userProfile = "user_profile"
    static let onboardingCompleted = "onboarding_completed"
    static let appSettings = "app_settings"
    static let lastSyncDate = "last_sync_date"
    
    // Keychain keys for sensitive data
    static let authToken = "auth_token"
    static let refreshToken = "refresh_token"
    static let userCredentials = "user_credentials"
}
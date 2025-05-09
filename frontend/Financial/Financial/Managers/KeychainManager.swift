//
//  KeychainManager.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//

import Foundation
import Security


enum KeychainKey: String {
    case accessToken
    case refreshToken
}

class KeychainService {
    static let standard = KeychainService()

    private init() {}
    
    @discardableResult
    func save(value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            print("KeychainService Error: Failed to convert string to data for key '\(key)'.")
            return false
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            print("KeychainService: Value for key '\(key)' saved successfully.")
            return true
        } else {
            if let errorString = SecCopyErrorMessageString(status, nil) {
                print("KeychainService Error saving value for key '\(key)': \(errorString)")
            } else {
                print("KeychainService Error saving value for key '\(key)': Unknown error, status \(status)")
            }
            return false
        }
    }

    func retrieve(forKey key: String) -> String? {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue!
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess {
            
            guard let retrievedData = dataTypeRef as? Data,
                  let value = String(data: retrievedData, encoding: .utf8) else {
                print("KeychainService Error: Failed to convert retrieved data to string for key '\(key)'.")
                return nil
            }
            print("KeychainService: Value for key '\(key)' retrieved successfully.")
            return value
        } else if status == errSecItemNotFound {
            
            print("KeychainService: Value for key '\(key)' not found.")
            return nil
        } else {
            if let errorString = SecCopyErrorMessageString(status, nil) {
                print("KeychainService Error retrieving value for key '\(key)': \(errorString)")
            } else {
                print("KeychainService Error retrieving value for key '\(key)': Unknown error, status \(status)")
            }
            return nil
        }
    }

    @discardableResult
    func delete(forKey key: String) -> Bool {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status == errSecSuccess || status == errSecItemNotFound {
            
            print("KeychainService: Value for key '\(key)' deleted successfully (or did not exist).")
            return true
        } else {
            
            if let errorString = SecCopyErrorMessageString(status, nil) {
                print("KeychainService Error deleting value for key '\(key)': \(errorString)")
            } else {
                print("KeychainService Error deleting value for key '\(key)': Unknown error, status \(status)")
            }
            return false
        }
    }

    // MARK: - Access Token Management

    func saveAccessToken(token: String?) {
        guard let token = token, !token.isEmpty else {
            
            print("KeychainService: Attempting to save nil or empty access token. Deleting existing one.")
            deleteAccessToken()
            return
        }
        save(value: token, forKey: KeychainKey.accessToken.rawValue)
    }

    func getAccessToken() -> String? {
        return retrieve(forKey: KeychainKey.accessToken.rawValue)
    }

    func deleteAccessToken() {
        delete(forKey: KeychainKey.accessToken.rawValue)
    }

    // MARK: - Refresh Token Management

    func saveRefreshToken(token: String?) {
        guard let token = token, !token.isEmpty else {
            print("KeychainService: Attempting to save nil or empty refresh token. Deleting existing one.")
            deleteRefreshToken()
            return
        }
        save(value: token, forKey: KeychainKey.refreshToken.rawValue)
    }

    func getRefreshToken() -> String? {
        return retrieve(forKey: KeychainKey.refreshToken.rawValue)
    }

    func deleteRefreshToken() {
        delete(forKey: KeychainKey.refreshToken.rawValue)
    }

    // MARK: - Helper to delete all known tokens (e.g., on logout)
    
    func deleteAllTokens() {
        print("KeychainService: Deleting all known tokens.")
        deleteAccessToken()
        deleteRefreshToken()
    }
}

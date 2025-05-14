//
//  TokenRefresher.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import Foundation

actor TokenRefresher {
    
    private var isRefreshing = false
    
    func refreshToken() async throws {
        
        guard !isRefreshing else {
            print("Refreshing token in progress...")
            throw NetworkError.other(URLError(.unknown, userInfo: ["Reason": "Refresh already in progress"]))
        }
        
        isRefreshing = true
        
        defer { isRefreshing = false }
        
        guard let refreshToken = KeychainService.standard.getRefreshToken() else {
            throw NetworkError.refreshFailed(nil)
        }
        
        guard let url = URL(string: "http://127.0.0.1:8000/api/users/refresh-token/") else {
            throw NetworkError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["refresh_token": refreshToken]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw NetworkError.encodingError(error)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.other(URLError(.badServerResponse))
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let refreshTokenResponse = try decoder.decode(UserResponse.self, from: data)
                    KeychainService.standard.saveAccessToken(token: refreshTokenResponse.accessToken)
                    KeychainService.standard.saveRefreshToken(token: refreshTokenResponse.refreshToken)
                    return
                } catch {
                    throw NetworkError.decodingError(error)
                }
            } else {
                print("Refresh token failed with status code: \(httpResponse.statusCode)")
                let errorMessage = String(data: data, encoding: .utf8)
                throw NetworkError.refreshFailed(NetworkError.clientError(statusCode: httpResponse.statusCode, massege: errorMessage))
            }
        } catch {
            if !(error is NetworkError) {
                throw NetworkError.refreshFailed(error)
            } else {
                throw error
            }
        }
        
        
    }
}

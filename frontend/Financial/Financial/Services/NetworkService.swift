//
//  NetworkService.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import Foundation

class NetworkService {
    static let shared = NetworkService()
    private let tokenRefresher = TokenRefresher()
    
    private init() {}
    
    func performRequest(_ request: URLRequest, requiresAuth: Bool = true) async throws -> (Data, URLResponse) {
        var currentRequest = request
        
        if requiresAuth {
            if let accessToken = KeychainService.standard.getAccessToken() {
                if currentRequest.value(forHTTPHeaderField: "Authorization") == nil {
                    currentRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                }
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: currentRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.other(URLError(.badServerResponse))
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return (data, response)
        case 401:
            guard requiresAuth else {
                throw NetworkError.unauthorized
            }
            
            do {
                try await tokenRefresher.refreshToken()
                
                guard let newAccessToken = KeychainService.standard.getAccessToken() else {
                    throw NetworkError.refreshFailed(nil)
                }
                
                currentRequest.setValue("Bearer \(newAccessToken)", forHTTPHeaderField: "Authorizetion")
                
                let (retryData, retryRespone) = try await URLSession.shared.data(for: currentRequest)
                
                guard let retryHttpResponse = retryRespone as? HTTPURLResponse else {
                    throw NetworkError.other(URLError(.badServerResponse))
                }
                
                if (200...299).contains(retryHttpResponse.statusCode) {
                    return (retryData, retryRespone)
                } else {
                    let errorMessage = String(data: retryData, encoding: .utf8)
                    
                    if (400...499).contains(retryHttpResponse.statusCode) {
                        throw NetworkError.clientError(statusCode: retryHttpResponse.statusCode, massege: errorMessage)
                    } else if (500...599).contains(retryHttpResponse.statusCode) {
                        throw NetworkError.serverError(statusCode: retryHttpResponse.statusCode, massege: errorMessage)
                    } else {
                        throw NetworkError.other(URLError(.unknown))
                    }
                }
            } catch {
                if !(error is NetworkError) {
                    throw NetworkError.refreshFailed(error)
                } else {
                    throw error
                }
            }
            
        case 400, 402...499:
            let errorMessage = String(data: data, encoding: .utf8)
            throw NetworkError.clientError(statusCode: httpResponse.statusCode, massege: errorMessage)
            
        case 500...599:
            let errorMessage = String(data: data, encoding: .utf8)
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, massege: errorMessage)
            
        default:
            throw NetworkError.other(URLError(.badServerResponse))
        }
    }
}

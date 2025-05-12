//
//  ProfileViewModel.swift
//  Financial
//
//  Created by KeeR ReeK on 12.05.2025.
//  Copyright (c) 2025 Financial

import Foundation

@MainActor
class ProfileViewViewModel: ObservableObject {
    
    private let coreDataService = CoreDataManager.shared
    let userDefaultsService = UserDefaultsService.shared
    @Published var showAlert = false
    @Published var showEditProfile = false
    @Published var showSettings = false
    @Published var showHelp = false
    @Published var imageName = ""
    
    init() {
        self.imageName = userDefaultsService.getSelectedImage()
    }
    
    func logoutApi() async -> Bool {
        
        do {
            try await ApiService.shared.logoutUser()
            return true
        } catch {
            print("logout error: \(error)")
            return false
        }
    }
    
    func logout() async -> Bool {
        KeychainService.standard.deleteAccessToken()
        KeychainService.standard.deleteRefreshToken()
        return true
    }
}

//
//  UserDefalutsManager.swift
//  Financial
//
//  Created by KeeR ReeK on 12.05.2025.
//  Copyright (c) 2025 Financial

import Foundation

class UserDefaultsService {
    static let shared = UserDefaultsService()
    
    private init() {}
    
    private let userDefaults = UserDefaults.standard
    
    private let keyImage = "selectedImage"
    
    func saveSelectedImage(_ imageName: String) {
        UserDefaults.standard.set(imageName, forKey: keyImage)
    }
    
    func getSelectedImage() -> String {
        return UserDefaults.standard.string(forKey: keyImage) ?? "firstBoy"
    }
}

//
//  EditingProfileViewModel.swift
//  Financial
//
//  Created by KeeR ReeK on 12.05.2025.
//  Copyright (c) 2025 Financial

import Foundation

class EditingProfileViewViewModel: ObservableObject {
    
    let userDefaultsService = UserDefaultsService.shared
    
    let availableImages = ["firstBoy", "secondBoy", "thirdBoy", "firstGirl", "secondGirl", "thirdGirl"]
    
    func saveImageName(_ name: String) {
        userDefaultsService.saveSelectedImage(name)
    }
}

//
//  LanguageManager.swift
//  Financial
//
//  Created by KeeR ReeK on 27.05.2025.
//

import SwiftUI

class LanguageSettings: ObservableObject {
    @AppStorage("selectedLanguage") var language: String = "ua" {
        didSet {
            objectWillChange.send()
        }
    }
}

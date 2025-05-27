//
//  FinancialApp.swift
//  Financial
//
//  Created by KeeR ReeK on 03.05.2025
//  Copyright (c) 2025 Financial

import SwiftUI

@main
struct FinancialApp: App {
    
    @StateObject var appState = AppState()
    @StateObject var languageSettings = LanguageSettings()
    let coreDataManager = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoggedIn {
                    MainView()
                        .environment(\.managedObjectContext, coreDataManager.context)
                } else {
                    StartView()
                }
            }
            .environmentObject(appState)
            .environmentObject(languageSettings)
            .preferredColorScheme(.dark)
            .environment(\.locale, .init(identifier: languageSettings.language))
        }
    }
}

class AppState: ObservableObject {
    @Published var isLoggedIn = KeychainManager.standard.getRefreshToken() != nil
}

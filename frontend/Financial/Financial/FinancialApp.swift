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
    let coreDataManager = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                MainView()
                    .environmentObject(appState)
                    .preferredColorScheme(.dark)
                    .environment(\.managedObjectContext, coreDataManager.context)
            } else {
                StartView()
                    .environmentObject(appState)
                    .preferredColorScheme(.dark)
            }
        }
    }
}

class AppState: ObservableObject {
    @Published var isLoggedIn = KeychainService.standard.getRefreshToken() != nil
}

//
//  NavigationStartManager.swift
//  Financial
//
//  Created by KeeR ReeK on 06.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

enum StartRoute: Hashable {
    case login
    case registration
    case budgetInput
}


final class NavigationServiceStart: ObservableObject {
    static let shared = NavigationServiceStart()
    
    @Published var startPath = NavigationPath()
    
    private init() {}
    
    func goToLoginView() {
        startPath.append(StartRoute.login)
    }
    
    func goToRegistrationView() {
        startPath.append(StartRoute.registration)
    }
    
    func goToBudgetInputView() {
        startPath.append(StartRoute.budgetInput)
    }
    
    func goToLoginWithRegistration() {
        startPath = NavigationPath()
        startPath.append(StartRoute.login)
    }
    
    func goToRegistrationWithLogin() {
        startPath = NavigationPath()
        startPath.append(StartRoute.registration)
    }
    
    func goBack() {
        startPath.removeLast()
    }
    
    func clearAll() {
        startPath.removeLast(startPath.count)
    }
}

//
//  LoginViewModel.swift
//  Financial
//
//  Created by KeeR ReeK on 06.05.2025.
//  Copyright (c) 2025 Financial

import Foundation

class LoginViewViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isValidEmail: Bool = true
    @Published var isPasswordVisible: Bool = false
    @Published var isValidPassword: Bool = true
    @Published var isLoginError: Bool = false
    @Published var isVisibleErrorResponse: Bool = false
    @Published var isChecked = false {
        didSet {
            if isChecked {
                print("Я тебе записав")
            }
        }
    }
    
    func validatePassword(_ password: String) {
        if isLoginError {
            isValidEmail = true
            isValidPassword = true
            isLoginError = false
        }
    }
    
    func validateEmail(_ email: String) {
        if isLoginError {
            isValidEmail = true
            isValidPassword = true
            isLoginError = false
        }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        isValidEmail = emailPredicate.evaluate(with: email)
    }
    
    func isAvaibleLogin() -> Bool {
        return !isValidEmail || !isValidPassword || password.isEmpty || email.isEmpty
    }
    
    func login() async -> Bool {
        
        do {
            try await ApiService.shared.login(email: email, password: password)
            if try await ApiService.shared.getUserInfo() {
                try await ApiService.shared.getTransactionsData()
                try await ApiService.shared.getAchievements()
            }
        } catch let error as NetworkError {
            
            if case .clientError(let statusCode, let message) = error {
                self.isValidEmail = false
                self.isValidPassword = false
                self.isLoginError = true
                return false
            }
            if case .other = error {
                self.isVisibleErrorResponse = true
                return false
            }
        } catch {
            print("Інша помилка: \(error)")
            DispatchQueue.main.async {
                self.isVisibleErrorResponse = true
            }
            return false
        }
        return true
    }
}

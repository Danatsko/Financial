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
}

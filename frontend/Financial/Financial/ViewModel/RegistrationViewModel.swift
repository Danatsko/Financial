//
//  RegistrationViewModel.swift
//  Financial
//
//  Created by KeeR ReeK on 06.05.2025.
//  Copyright (c) 2025 Financial

import Foundation

class RegistrationViewViewModel: ObservableObject {
    
    static let shared = RegistrationViewViewModel()
    
    @Published var loginService: Bool = false
    @Published var monthlyBudget: String = ""
    @Published var balance: Double = 0
    @Published var email: String = ""
    @Published var isValidEmail: Bool = true
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isPasswordVisible: Bool = false
    @Published var isConfirmPasswordVisible: Bool = false
    @Published var isValidPassword: Bool = true
    @Published var isValidConfirmPassword: Bool = true
    @Published var isVisibleErrorResponse: Bool = false
    
    func validatePassword(_ password: String) {
        isValidConfirmPassword = password == self.password
        isValidPassword = password == self.confirmPassword
    }
    
    func validateEmail(_ email: String) {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        isValidEmail = emailPredicate.evaluate(with: email)
    }
    
    func isAvaibleRegistration() -> Bool {
        return !isValidEmail || !isValidPassword || !isValidConfirmPassword || password.isEmpty || email.isEmpty || confirmPassword.isEmpty
    }
    
    func formatNumber(_ number: String) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        numberFormatter.groupingSize = 3
        if let formattedNumber = numberFormatter.number(
            from: number.replacingOccurrences(of: ",", with: "")
        ) {
            return numberFormatter.string(from: formattedNumber) ?? number
        } else {
            return number
        }
    }
    
    func isAvaibleBudget() -> Bool {
        monthlyBudget.isEmpty
    }
}

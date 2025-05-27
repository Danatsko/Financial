//
//  EditingProfileViewModel.swift
//  Financial
//
//  Created by KeeR ReeK on 12.05.2025.
//  Copyright (c) 2025 Financial

import Foundation

class EditingProfileViewViewModel: ObservableObject {
    
    @Published var changeEmail = ""
    @Published var changeMonthBudget = ""
    @Published var isValidEmail: Bool = true
    
    let userDefaultsService = UserDefaultsService.shared
    
    let availableImages = ["firstBoy", "secondBoy", "thirdBoy", "firstGirl", "secondGirl", "thirdGirl"]
    
    func saveImageName(_ name: String) {
        userDefaultsService.saveSelectedImage(name)
    }
    
    func validateEmail(_ email: String) {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        isValidEmail = emailPredicate.evaluate(with: email)
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
    
    @MainActor
    func isChangeAvailable() -> Bool {
        if !changeEmail.isEmpty || !changeMonthBudget.isEmpty {
            if isValidEmail {
                if CoreDataManager.shared.getEmail() != changeEmail {
                    return true
                }
                if let budget = Int(changeMonthBudget.replacingOccurrences(of: ",", with: "")),
                   budget != CoreDataManager.shared.getMonthlyBudget()
                {
                    return true
                }
            }
        }
        return false
    }
    
    func changeDataUser() async -> Bool {
        if !changeEmail.isEmpty && !changeMonthBudget.isEmpty {
            do {
                try await ApiService.shared.changeDataUser(
                    email: changeEmail,
                    monthBudget: Int(changeMonthBudget.replacingOccurrences(of: ",", with: "")) ?? 0
                )
                return true
            } catch {
                print(error)
            }
        } else if !changeEmail.isEmpty {
            do {
                try await ApiService.shared.changeDataUser(email: changeEmail, monthBudget: CoreDataManager.shared.getMonthlyBudget())
                return true
            } catch {
                print(error)
            }
        } else if !changeMonthBudget.isEmpty {
            do {
                try await ApiService.shared.changeDataUser(
                    email: CoreDataManager.shared.getEmail(),
                    monthBudget: Int(changeMonthBudget.replacingOccurrences(of: ",", with: "")) ?? 0
                )
                print(changeMonthBudget)
                return true
            } catch {
                print(error)
            }
        }
        return false
    }
}

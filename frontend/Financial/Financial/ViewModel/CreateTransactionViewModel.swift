//
//  CreateTransactionViewModel.swift
//  Financial
//
//  Created by KeeR ReeK on 11.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

@MainActor
class CreateTransactionViewModel: ObservableObject {
    
    private let coreDataService = CoreDataManager.shared
    
    let customFont = Font.custom("Montserrat-SemiBold", size: 20)
    let expenseCategories = ["products", "cafes_restaurants", "utilities_home", "entertainment", "devices", "transports", "animals", "beauty_health", "clothing_accessories", "charity", "other_sources_of_costs"]
    let incomeCategories = ["business", "payments", "other_sources_of_income"]
    let paymentArray = ["card", "cash", "crypto", "otherPayment"]
    let emptyCategories = [""]
    
    @Published var type: String = "" {
        didSet {
            updatePickedCategory()
        }
    }
    @Published var incomeButtonState: Bool = false
    @Published var costsButtonState: Bool = false
    @Published var amount = 0
    @Published var title: String = ""
    @Published var descriptionText: String = ""
    @Published var pickedCategory: String = ""
    @Published var pickedPayment: String = "card"
    @Published var dateCreate = Date()
    @Published var minDate = Date()
    @Published var maxDate = Date()
    
    private var chosenLocale = Locale(identifier: "uk_UA")
    
    var formatter: NumberFormatter {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.minimumFractionDigits = 2
        fmt.maximumFractionDigits = 2
        fmt.locale = chosenLocale
        return fmt
    }
    
    func buttonToggle(isIncomeButton income: Bool) {
        if income {
            incomeButtonState = true
            costsButtonState = false
            type = "incomes"
        } else {
            incomeButtonState = false
            costsButtonState = true
            type = "costs"
        }
        print(type)
    }
    
    init() {
        minDate = coreDataService.getCreatinDate() ?? Date()
        maxDate = Date()
    }
    
    func selectoryCategory() -> [String] {
        type.isEmpty ? emptyCategories : type == "incomes" ? incomeCategories : expenseCategories
    }
    
    private func updatePickedCategory() {
        let categories = selectoryCategory()
        pickedCategory = categories.first ?? ""
        pickedPayment = paymentArray.first ?? ""
    }
    
    func createTransaction() async -> (Bool, String?) {
        
        guard isFormValid else { return (false , nil) }
        
        do {
            try await ApiService.shared.createTransaction(
                type: type,
                amount: Double(amount) / 100,
                title: title,
                payment_method: pickedPayment,
                description: descriptionText,
                category: pickedCategory,
                creation_date: dateCreate
            )
            return (true, nil)
        } catch let error as NetworkError {
            if case .refreshFailed = error {
                return (false, "logout")
            }
            return (false , nil)
        } catch {
            print("Create transaction error: \(error)")
            return (false , nil)
        }
    }
    
    func resetForm() {
        type = ""
        incomeButtonState = false
        costsButtonState = false
        amount = 0
        title = ""
        descriptionText = ""
        pickedCategory = ""
        pickedPayment = ""
        dateCreate = Date()
    }
    
    var isFormValid: Bool {
        !type.isEmpty && amount != 0 && !title.isEmpty && !pickedCategory.isEmpty && !pickedPayment.isEmpty
    }
}


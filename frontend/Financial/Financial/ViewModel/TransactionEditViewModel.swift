//
//  TransactionEditViewModel.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

class TransactionEditViewModel: ObservableObject {
    
    private let transaction: Transaction
    
    @Binding var path: NavigationPath
    
    let customFont = Font.custom("Montserrat-SemiBold", size: 20)
    let costsCategories = [
        "groceries",
        "cafes",
        "utilities",
        "entertainment",
        "equipment",
        "transportation",
        "animals",
        "health",
        "clothing",
        "charity",
        "otherExpensen"
    ]
    let paymentArray = [
        "card",
        "cash",
        "crypto",
        "otherPayment"
    ]
    let incomeCategories = [
        "business",
        "payments",
        "otherIncome"
    ]
    
    @Published var title: String
    @Published var descriptionText: String = ""
    @Published var pickedCategory: String = ""
    @Published var pickedPayment: String = ""
    @Published var dateCreate = Date()
    @Published var amount: Int
    
    private var chosenLocale = Locale(identifier: "uk_UA")
    
    var minDate: Date {
        Calendar.current.dateInterval(of: .month, for: transaction.date!)?.start ?? Date()
    }
    var maxDate: Date {
        Calendar.current.dateInterval(of: .month, for: transaction.date!)?.end.addingTimeInterval(-1) ?? Date()
    }
    
    
    init(transaction: Transaction, path: Binding<NavigationPath>) {
        self.transaction = transaction
        self.title = transaction.title ?? ""
        self.descriptionText = transaction.descriptionText ?? ""
        self.pickedPayment = transaction.paymentMethod ?? ""
        self.pickedCategory = transaction.category ?? ""
        self.dateCreate = transaction.date ?? Date()
        self.amount = Int(transaction.amount * 100)
        self._path = path
    }
    
    var formatter: NumberFormatter {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.minimumFractionDigits = 2
        fmt.maximumFractionDigits = 2
        fmt.locale = chosenLocale
        return fmt
    }
    
    func selectoryCategory() -> [String] {
        transaction.type == "Доходи" ? incomeCategories : costsCategories
    }
    
    private func updatePickedCategory() {
        let categories = selectoryCategory()
        pickedCategory = categories.first ?? ""
    }
    
    func updateTransaction() async -> (Bool, String?) {
        guard isFormValid else { return (false, nil) }
        
        do {
            try await ApiService.shared.updateTransaction(
                server_id: Int(transaction.serverId),
                type: transaction.type ?? "",
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
            return (false , "logout")
        } catch {
            print("Update transaction error: \(error)")
            return (false, nil)
        }
    }
    
    func resetForm() {
        amount = 0
        title = ""
        descriptionText = ""
        pickedCategory = ""
        pickedPayment = ""
        dateCreate = Date()
    }
    
    var isFormValid: Bool {
        amount != 0 && !title.isEmpty && !pickedCategory.isEmpty
    }
}



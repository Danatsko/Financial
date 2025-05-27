//
//  TransactionDetailViewViewModel.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import Foundation
import SwiftUI

class TransactionDetailViewModel: ObservableObject {
    
    let transaction: Transaction
    
    @Binding var path: NavigationPath
    
    init(transaction: Transaction, path: Binding<NavigationPath>) {
        self.transaction = transaction
        self._path = path
    }
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        return dateFormatter.string(from: transaction.date ?? Date())
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: transaction.amount)) ?? "0.00"
    }
    
}

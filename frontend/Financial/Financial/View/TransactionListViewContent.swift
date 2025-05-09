//
//  TransactionListViewContent.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI
import CoreData
import AVFoundation

// MARK: - Contents of the transaction list
struct TransactionListViewContent: View {
    var coreDataManager = CoreDataManager.shared
    @Binding var path: NavigationPath
    @EnvironmentObject var appState: AppState
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<Transaction>
    
    private var emptyListView: some View {
        Text(NSLocalizedString("transactionsEmpty", comment: "Message when transactions list is empty"))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("BackroundColor"))
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }
    
    private var transactionListView: some View {
        let sortedGroups = groupedTransactions.sorted { $0.key > $1.key }

        return ForEach(sortedGroups, id: \.key) { month, transactions in
            Section(header: Text(month).foregroundColor(.white).font(.headline)) {
                ForEach(transactions, id: \.self) { transaction in
                    TransactionListItemView(transaction: transaction, path: $path)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 10)
                        .swipeActions(edge: .trailing) {
                            deleteSwipeButton(for: transaction)
                        }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
        }
    }
    
    private func deleteSwipeButton(for transaction: Transaction) -> some View {
        Button(role: .destructive) {
            Task {
                do {
                    try await ApiService.shared.deleteTransaction(id: Int(transaction.serverId))
                    coreDataManager.deleteTransaction(transaction: transaction)
                    print("Видалено упішно")
                } catch let error as NetworkError {
                    if case .refreshFailed = error {
                        coreDataManager.shared.deleteUser()
                        appState.isLoggedIn = false
                    }
                } catch {
                    print(error)
                }
            }
        } label: {
            Label(NSLocalizedString("delete", comment: "Delete button"), systemImage: "trash")
        }
        .tint(.red)
    }
    
    private var groupedTransactions: [String: [Transaction]] {
        Dictionary(grouping: transactions) { transaction in
            let date = transaction.date ?? Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "LLLL yyyy"
            return formatter.string(from: date)
        }
    }
    
    var body: some View {
        List {
            if transactions.isEmpty {
                emptyListView
            } else {
                transactionListView
            }
        }
        .listStyle(.plain)
        .background(Color("BackroundColor"))
    }
}


// MARK: - The main component of the transaction list item
struct TransactionListItemView: View {
    @ObservedObject var transaction: Transaction
    @Binding var path: NavigationPath

    
    var body: some View {
        HStack {
            CategoryIconView(transaction: transaction)
            
            TransactionInfoView(transaction: transaction)
            
            Spacer()
            
            TransactionAmountView(transaction: transaction)
        }
        .padding()
        .background(Color("TextFieldBackround"))
        .cornerRadius(30)
        .contentShape(Rectangle())
        .onLongPressGesture {
            AudioServicesPlaySystemSound(1519)
            path.append(TransactionRoute.detail(transaction))
        }
    }
}

// MARK: - Component of the transaction amount
struct TransactionAmountView: View {
    @ObservedObject var transaction: Transaction
    
    var body: some View {
        let type = transaction.type ?? "expenses"
        
        Text("\(type == "incomes" ? "+" : "-") ₴\(formattedTransactionAmount(transaction.amount))")
            .foregroundColor(.white)
    }
}

// MARK: - Component of information about the transaction
struct TransactionInfoView: View {
    @ObservedObject var transaction: Transaction
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(transaction.title ?? "Без назви")
                .lineLimit(1)
                .foregroundColor(.white)
                .font(.custom("Montserrat-SemiBold", size: 22))
            
            Text(transaction.descriptionText ?? "Без опису")
                .lineLimit(1)
                .font(.custom("Montserrat", size: 14))
        }
    }
}

// MARK: - Component of the category icon
struct CategoryIconView: View {
    @ObservedObject var transaction: Transaction
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .overlay(
                    Image("backroundIconCategory")
                        .resizable()
                        .scaledToFit()
                        .allowsHitTesting(false)
                )
                .frame(width: 50, height: 50)
            
            Image(systemName: imageName(for: transaction.category ?? ""))
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
        }
        .contentShape(Rectangle())
    }
}

// MARK: - A helper function for getting the category icon
func formattedTransactionAmount(_ amount: Double) -> String {
    if amount >= 1000000 {
        return "\(Int(amount / 1000000)) млн."
    } else if amount >= 1000 {
        return "\(Int(amount / 1000)) тис."
    } else {
        return String(format: "%.2f", amount)
    }
}

// MARK: - A helper function for getting the category icon
func imageName(for category: String) -> String {
    switch category {
    case "products": return "cart"
    case "cafes_restaurants": return "fork.knife"
    case "utilities_home": return "bolt"
    case "entertainment": return "gamecontroller"
    case "devices": return "laptopcomputer"
    case "transport": return "car"
    case "animals": return "pawprint"
    case "beauty_health": return "heart.text.square"
    case "clothing_accessories": return "tshirt"
    case "charity": return "gift"
    case "other_sources_of_costs": return "questionmark"
    case "business": return "building.2"
    case "payments": return "creditcard"
    case "other_sources_of_income": return "banknote"
    default: return "questionmark"
    }
}

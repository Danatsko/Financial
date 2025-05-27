//
//  CategoryTransactionsSheetView.swift
//  Financial
//
//  Created by KeeR ReeK on 18.05.2025.
//

import SwiftUI

struct CategoryTransactionsSheetView: View {
    
    let categoryName: String
    let transactions: [TransactionApi]
    
    var body: some View {
        VStack {
            Text(categoryName)
                .foregroundStyle(.white)
                .padding()
            
            Spacer()
            
            ScrollView {
                if transactions.isEmpty {
                    Text("No transactions")
                        .foregroundStyle(.white)
                }
                ForEach(transactions) { transaction in
                    TransactionItemView(transaction: transaction)
                        .padding()
                }
            }
            
            Spacer()
        }
    }
    
}


struct TransactionItemView: View {
    
    var transaction: TransactionApi

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .overlay(
                        Image("backroundIconCategory")
                            .resizable()
                            .scaledToFit()
                            .allowsHitTesting(false)
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: imageName(for: transaction.category))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            .contentShape(Rectangle())
            
            
            VStack(alignment: .leading) {
                Text(transaction.title)
                    .lineLimit(1)
                    .foregroundColor(.white)
                    .font(.custom("Montserrat-SemiBold", size: 22))
                
                Text(transaction.description)
                    .lineLimit(1)
                    .font(.custom("Montserrat", size: 14))
            }
            
            Spacer()
            
            let type = transaction.type
            
            Text("\(type == "incomes" ? "+" : "-") ₴\(formattedTransactionAmount(transaction.amount))")
                .foregroundColor(.white)
        }
        .padding()
        .background(Color("TextFieldBackround"))
        .cornerRadius(30)
        .contentShape(Rectangle())
    }
}

//
//  TypeButtonsViewStatistics.swift
//  Financial
//
//  Created by KeeR ReeK on 11.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct TypeButtonsViewStatistics: View {
    
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        
        let formattedStringIncomes = String(format: "%.2f", viewModel.amountIncomes)
        let formattedStringCosts = String(format: "%.2f", viewModel.amountCosts)
        
        VStack(spacing: 15) {
            CategoryButtonStatisticsView(
                amount: formattedStringIncomes,
                type: "Доходи",
                title: "income",
                imageName: "arrowUp",
                isDisabled: viewModel.incomeButtonState) {
                    viewModel.buttonToggle(isIncomeButton: true)
                }
            CategoryButtonStatisticsView(
                amount: formattedStringCosts,
                type: "Витрати",
                title: "expense",
                imageName: "arrowDown",
                isDisabled: viewModel.costsButtonState) {
                    viewModel.buttonToggle(isIncomeButton: false)
                }
        }
    }
}


struct CategoryButtonStatisticsView: View {
    
    var amount: String
    let type: String
    let title: String
    let imageName: String
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 10) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 60)
                
                VStack(alignment: .leading) {
                    Text(LocalizedStringKey(title))
                        .foregroundColor(.white)
                        .font(.custom("Montserrat-SemiBold", size: 15))
                    
                    Spacer()
                    
                    Text("\(amount)₴")
                        .foregroundColor(.white)
                        .font(.custom("Montserrat-SemiBold", size: 15))
                    
                    Spacer()
                }
            }
            .padding(10)
            .frame(width: 150, height: 70)
        }
        .background(type == "Доходи" ? Color.buttonIncome : Color.buttonExpense)
        .cornerRadius(18)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

//
//  TypeButtonsViewNewTransaction.swift
//  Financial
//
//  Created by KeeR ReeK on 11.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct TypeButtonsViewNewTransaction: View {
    @Binding var selectedCategory: String
    @Binding var incomeButtonState: Bool
    @Binding var costsButtonState: Bool

    let incomeAction: () -> Void
    let costsAction: () -> Void

    var body: some View {
        HStack(spacing: 30) {
            CategoryButtonNewTransactionView(
                title: "income",
                imageName: "arrowUp",
                backgroundName: "incomeBackround",
                isDisabled: incomeButtonState,
                action: incomeAction
            )
            CategoryButtonNewTransactionView(
                title: "expense",
                imageName: "arrowDown",
                backgroundName: "growthBackround",
                isDisabled: costsButtonState,
                action: costsAction
            )
        }
        .padding(.horizontal, 5)
    }
}

struct CategoryButtonNewTransactionView: View {
    let title: String
    let imageName: String
    let backgroundName: String
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                Text(LocalizedStringKey(title))
                    .foregroundColor(.white)
                    .font(.custom("Montserrat-SemiBold", size: 20))
                Spacer()
            }
            .padding(.horizontal, 5)
            .frame(height: 65)
            .background(
                Image(backgroundName)
                    .resizable()
                    .scaledToFill()
            )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

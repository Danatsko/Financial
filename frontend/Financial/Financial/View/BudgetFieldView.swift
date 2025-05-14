//
//  BudgetFieldView.swift
//  Financial
//
//  Created by KeeR ReeK on 12.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct BudgetFieldView: View {
    @Binding var budget: String
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(
                "",
                text: $budget,
                prompt: Text("email")
                    .foregroundColor(Color("PlaceHolderColor"))
                    .font(.custom("Montserrat-SemiBold", size: 16))
            )
            .keyboardType(.numberPad)
            .padding(EdgeInsets(top: 20, leading: 50, bottom: 20, trailing: 20))
            .overlay(
                HStack {
                    Text("₴")
                        .foregroundColor(.gray)
                        .padding(20)
                    Spacer()
                }
            )
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .background(Color("TextFieldBackround"))
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}

//
//  TransactionDetailRowView.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct TransactionDetailRowView: View {
    let title: String
    let value: String
    let height: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.custom("Montserrat-Bold", size: 21))
            
            RoundedRectangle(cornerRadius: 30)
                .fill(Color("TextFieldBackround"))
                .frame(height: CGFloat(height))
                .overlay(
                    ScrollView {
                        Text(value)
                            .font(.custom("Montserrat-SemiBold", size: 18))
                            .padding()
                        
                    },
                    alignment: .leading
                )
            
        }
    }
}

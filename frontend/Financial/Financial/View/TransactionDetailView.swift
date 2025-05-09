//
//  TransactionDetailView.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct TransactionDetailView: View {
    
    @ObservedObject var viewModel: TransactionDetailViewModel
    
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color("TextFieldBackround"))
                    .frame(height: 80)
                    .overlay(
                        Text("\(viewModel.transaction.type == "incomes" ? "+" : "-") ₴\(viewModel.formattedAmount)")
                            .font(.custom("Montserrat-Bold", size: 25))
                        
                    )
                
                TransactionDetailRowView(title: "title", value: viewModel.transaction.title ?? "", height: 70)
                TransactionDetailRowView(title: "description", value: viewModel.transaction.descriptionText ?? "", height: 100)
                TransactionDetailRowView(title: "category", value: viewModel.transaction.category ?? "", height: 70)
                TransactionDetailRowView(title: "paymentMethod", value: viewModel.transaction.paymentMethod ?? "", height: 70)
                TransactionDetailRowView(title: "date", value: viewModel.formattedDate, height: 70)
                
                Button {
                    viewModel.path.append(TransactionRoute.edit(viewModel.transaction))
                } label: {
                    Text("editing")
                        .font(.custom("Montserrat-SemiBold", size: 18))
                        .padding()
                        .foregroundColor(.white)
                        .padding(.bottom, 5)
                }
                .padding()
                .background(
                    Image("growthBackround")
                        .resizable()
                        .scaledToFit()
                )
                
            }
            .padding()
            .navigationTitle(viewModel.transaction.type ?? "No value")
        }
        .toolbar(.hidden, for: .tabBar)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackroundColor"))
    }
}

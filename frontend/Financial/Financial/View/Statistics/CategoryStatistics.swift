//
//  CategoryStatistics.swift
//  Financial
//
//  Created by KeeR ReeK on 11.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct CategoryStatistics: View {
    
    @ObservedObject var viewModel: StatisticsViewModel
    @Binding var isPresented: Bool

    var body: some View {
        ScrollView (.horizontal) {
            HStack {
                if viewModel.displayableCategoriesIncomes.isEmpty {
                    Text("Data for categories not available")
                } else {
                    if viewModel.incomeButtonState {
                        ForEach(viewModel.displayableCategoriesIncomes) { category in
                            CircularProgressView(
                                percentage: category.percentage,
                                label: category.localizedName,
                                transactions: category.transactions
                            )
                            .onTapGesture {
                                viewModel.arrayTransactionApi = category.transactions
                                viewModel.categoryName = category.localizedName
                                print(viewModel.categoryName)
                                isPresented = true
                            }
                        }
                    } else {
                        ForEach(viewModel.displayableCategoriesCosts) { category in
                            CircularProgressView(
                                percentage: category.percentage,
                                label: category.localizedName,
                                transactions: category.transactions
                            )
                            .onTapGesture {
                                viewModel.arrayTransactionApi = category.transactions
                                viewModel.categoryName = category.localizedName
                                print(viewModel.categoryName)
                                isPresented = true
                            }
                        }
                    }
                }
            }
        }
    }
}

//
//  CategoryStatistics.swift
//  Financial
//
//  Created by KeeR ReeK on 11.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct CategoryStatistics: View {
    
    @ObservedObject var viewModel: StatisticsViewModel

    var body: some View {
        ScrollView (.horizontal) {
            HStack {
                if viewModel.displayableCategoriesIncomes.isEmpty {
                    Text("Дані про категорії відсутні")
                } else {
                    if viewModel.incomeButtonState {
                        ForEach(viewModel.displayableCategoriesIncomes) { category in
                            CircularProgressView(
                                percentage: category.percentage,
                                label: category.localizedName,
                                transactions: category.transactions
                            )
                        }
                    } else {
                        ForEach(viewModel.displayableCategoriesCosts) { category in
                            CircularProgressView(
                                percentage: category.percentage,
                                label: category.localizedName,
                                transactions: category.transactions
                            )
                        }
                    }
                }
            }
        }
    }
}

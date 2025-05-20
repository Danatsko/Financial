//
//  RecommendationsView.swift
//  Financial
//
//  Created by KeeR ReeK on 14.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct RecommendationsView: View {
    
    @StateObject var viewModel = RecommendationsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                
                MessageBubble(
                    text: "Hello, show me my financial statement for last month",
                    isSender: true,
                    bubbleColor: Color.orange.opacity(0.8),
                    textColor: .black
                )
                
                MessageBubble(
                    text: "Hi, here's your financial report for last month",
                    isSender: false,
                    bubbleColor: Color(white: 0.9),
                    textColor: .black
                )
                
                if viewModel.isLoading {
                    ProgressView("Downloading recommendations...")
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else {
                    ForEach(viewModel.messages, id: \.self) { message in
                        MessageBubble(
                            text: message,
                            isSender: false,
                            bubbleColor: Color(white: 0.9),
                            textColor: .black
                        )
                    }
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                do {
                    let jsonData = try await ApiService.shared.getRecommendations(monthlyBudget: CoreDataManager.shared.getMonthlyBudget())
                    viewModel.fetchAndProcessRecommendations(jsonData: jsonData)
                    print("Recommendations sussessfully fetched")
                } catch {
                    throw error
                }
            }
        }
    }
}

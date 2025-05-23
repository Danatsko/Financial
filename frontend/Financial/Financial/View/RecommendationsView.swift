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
                    text: .localizedFormat("user.startConversation"),
                    isSender: true,
                    bubbleColor: Color.orange.opacity(0.8),
                    textColor: .black
                )
                
                MessageBubble(
                    text: .localizedFormat("greeting.requestReport"),
                    isSender: false,
                    bubbleColor: Color(white: 0.9),
                    textColor: .black
                )
                
                MessageBubble(
                    text: .localizedFormat("greeting.reportReady"),
                    isSender: false,
                    bubbleColor: Color(white: 0.9),
                    textColor: .black
                )
                
                if viewModel.isLoading {
                    MessageBubble(
                        text: .localizedFormat("recommendations.downloading"),
                        isSender: false,
                        bubbleColor: Color(white: 0.9),
                        textColor: .black
                    )
                } else if let _ = viewModel.errorMessage {
                    MessageBubble(
                        text: .localizedFormat("recommendations.downloading"),
                        isSender: false,
                        bubbleColor: Color(white: 0.9),
                        textColor: .black
                    )
                } else if viewModel.messages.isEmpty {
                    MessageBubble(
                        text: .localizedFormat("recommendations.downloading"),
                        isSender: false,
                        bubbleColor: Color(white: 0.9),
                        textColor: .black
                    )
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
                } catch {
                    throw error
                }
            }
        }
    }
}

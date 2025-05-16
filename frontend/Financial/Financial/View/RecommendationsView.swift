//
//  RecommendationsView.swift
//  Financial
//
//  Created by KeeR ReeK on 14.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct RecommendationsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                MessageBubble(
                    text: "Hi, how are you?",
                    isSender: false,
                    bubbleColor: Color.gray,
                    textColor: .black
                )

                MessageBubble(
                    text: "Everything is fine, thank you! How about you? This is a very long message to test how it will expand and transfer to new lines.",
                    isSender: true,
                    bubbleColor: Color.blue,
                    textColor: .white
                )

                MessageBubble(
                    text: "Great!",
                    isSender: false,
                    bubbleColor: Color.gray,
                    textColor: .black
                )
            }
        }
        .padding()
    }
}

#Preview {
    RecommendationsView()
}

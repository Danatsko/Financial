//
//  MessageBubble.swift
//  Financial
//
//  Created by KeeR ReeK on 14.05.2025.
//

import SwiftUI

struct MessageBubble: View {
    let text: String
    let isSender: Bool
    let bubbleColor: Color
    let textColor: Color

    var body: some View {
        HStack {
            if isSender {
                Spacer()
            }

            VStack(alignment: isSender ? .trailing : .leading, spacing: 0) {
                Text(text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundColor(textColor)
                    .background(bubbleColor)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 1, y: 2)

            }
            .padding(.horizontal, 10)
            .padding(isSender ? .leading : .trailing, 50)

            if !isSender {
                Spacer()
            }
        }
    }
}

#Preview {
    RecommendationsView()
}

//
//  ProgressGoalView.swift
//  Financial
//
//  Created by KeeR ReeK on 11.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct ProgressGoalView: View {
    let progress: Double
    let current: Int
    let goal: Int
    let text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(LocalizedStringKey(text))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(current) / \(goal)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 8)
                        .foregroundColor(Color.gray.opacity(0.3))
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                        .foregroundColor(progress >= 1.0 ? Color.green : Color.orange)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color("TextFieldBackround"))
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
    }
}

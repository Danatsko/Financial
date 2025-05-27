//
//  CircularProgressView.swift
//  Financial
//
//  Created by KeeR ReeK on 11.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct CircularProgressView: View {
    
    var percentage: Double
    var label: String
    var transactions: [TransactionApi]
    let color: Color = Color("CircleStatistics")
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color("CircleStatisticsBackround").opacity(0.7), lineWidth: 2)
                
                Circle()
                    .trim(from: 0, to: (percentage / 100))
                    .stroke(Color("CircleStatistics"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .shadow(color: color.opacity(0.3), radius: 2, x: 2, y: 2)
                    .shadow(color: color.opacity(0.3), radius: 2, x: -2, y: -2)
                    .shadow(color: color.opacity(0.3), radius: 2, x: 2, y: -2)
                    .shadow(color: color.opacity(0.3), radius: 2, x: -2, y: 2)
                
                Text("\(Int(percentage))%")
                    .font(.custom("Montserrat-SemiBold", size: 18))
                    .foregroundColor(.white)
            }
            .frame(width: 70, height: 70)
            .padding(5)
            
            Text(label)
                .font(.custom("Montserrat-SemiBold", size: 14))
                .foregroundColor(.white)
        }
        .padding()
        .frame(width: 130, height: 130)
        .background(Color("TextFieldBackround"))
        .cornerRadius(24)
    }
}

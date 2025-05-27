//
//  StatisticsPDFView.swift
//  Financial
//
//  Created by KeeR ReeK on 24.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct StatisticsPDFView: View {
    
    let data: PDFStatisticsData
    
    private var currentFormattedDate: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .short
            formatter.locale = Locale.current
            return formatter.string(from: Date())
        }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Звіт")
                .font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)

            Group {
                Text("Період: \(data.period)")
                Text("Тип: \(data.type)")
                Text("Загальна сума: \(String(format: "%.2f", data.totalAmount))")
            }
            .font(.system(size: 14, weight: .semibold))
            .padding(.bottom, 5)

            Divider().padding(.vertical, 10)

            Text("Розподіл по категоріях:")
                .font(.system(size: 18, weight: .bold))
                .padding(.bottom, 5)

            if data.categories.isEmpty {
                 Text("Немає даних по категоріях.")
                     .font(.system(size: 12))
                     .foregroundColor(.gray)
            } else {
                ForEach(data.categories, id: \.name) { category in
                    HStack {
                        Text(category.name)
                        Spacer()
                        Text("\(String(format: "%.1f", category.percentage))%")
                    }
                    .font(.system(size: 12))
                    .padding(.vertical, 1)
                }
            }
            
            Spacer()
            
            Text("Згенеровано: \(currentFormattedDate)")
                .font(.system(size: 9))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(40)
        .frame(width: 595, height: 842)
        .background(Color.white)
        .foregroundColor(.black)
    }
}


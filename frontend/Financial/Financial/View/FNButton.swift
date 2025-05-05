//
//  FNButton.swift
//  Financial
//
//  Created by KeeR ReeK on 05.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct FNButton: View {
    let text: String
    let color: Color
    let action: () async -> Void
    
    var body: some View {
        Button(action: {
            Task {
                await action()
            }
        }) {
            Text(text)
                .font(.custom("Montserrat-SemiBold", size: 20))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, maxHeight: 55)
                .background(color)
                .cornerRadius(8)
        }
    }
}


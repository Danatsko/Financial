//
//  LogoView.swift
//  Financial
//
//  Created by KeeR ReeK on 05.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct LogoView: View {
    var body: some View {
        Label {
            Text("Financial")
                .font(.custom("Lexend-SemiBold", size: 40))
        } icon: {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 63, height: 67)
        }
        .foregroundColor(Color.white)
        .padding(.bottom, 66)
    }
}

//
//  OrDividerView.swift
//  Financial
//
//  Created by KeeR ReeK on 06.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct OrDividerView: View {
    var body: some View {
        HStack {
            VStack {
                Divider()
                    .frame(height: 1)
                    .background(Color.gray)
            }
            Text("logWith")
                .foregroundColor(Color("PlaceHolderColor"))
                .font(.custom("Montserrat-SemiBold", size: 10))
            VStack {
                Divider()
                    .frame(height: 1)
                    .background(Color.gray)
            }
        }
        .padding()
    }
}

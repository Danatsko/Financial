//
//  StartView.swift
//  Financial
//
//  Created by KeeR ReeK on 05.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct StartView: View {
    
    var body: some View {
        VStack {
            
            LogoView()
            
            FNButton(text: "login", color: Color.white) {
                
            }
            
            FNButton(text: "createAccount", color: Color("ButtonLoginColor")) {
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color("BackroundColor"))
    }
}

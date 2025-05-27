//
//  HelpView.swift
//  Financial
//
//  Created by KeeR ReeK on 12.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI
import AVKit

struct HelpView: View {
    
    private let player = AVPlayer(url: Bundle.main.url(forResource: "HelpView", withExtension: "mov")!)
    
    var body: some View {
        VideoPlayer(player: player)
            .padding()
    }
}

#Preview {
    HelpView()
}

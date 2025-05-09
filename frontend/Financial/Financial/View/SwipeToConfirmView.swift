//
//  SwipeToConfirmView.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

import SwiftUI
import AVFoundation

struct SwipeToConfirmView: View {
    @State private var offset: CGFloat = 0
    @State private var isConfirmed: Bool = false
    @State private var sliderWidth: CGFloat = 0
    let action: () -> Void
    
    var body: some View {
        ZStack {
            // Смуга для свайпу
            RoundedRectangle(cornerRadius: 40)
                .fill(Color("TextFieldBackround"))
                .frame(height: 60)
                .overlay(
                    GeometryReader { geometry in
                        Color.clear.onAppear {
                            sliderWidth = geometry.size.width
                        }
                    }
                )
            
            HStack {
                RoundedRectangle(cornerRadius: 40)
                    .fill(isConfirmed ? Color.green : Color.blue)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image("swipe")
                            .resizable()
                            .scaledToFit()
                    )
                    .offset(x: offset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                if !isConfirmed {
                                    let newOffset = gesture.translation.width
                                    // Обмеження руху
                                    offset = min(max(newOffset, 0), sliderWidth - 60)
                                }
                            }
                            .onEnded { _ in
                                
                                if offset >= sliderWidth - 60 {
                                    withAnimation {
                                        offset = sliderWidth - 60
                                        isConfirmed = true
                                    }
                                    
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    
                                    action()
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        withAnimation {
                                            offset = 0
                                            isConfirmed = false
                                        }
                                    }
                                } else {
                                    withAnimation {
                                        offset = 0
                                    }
                                }
                            }
                    )
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }
}


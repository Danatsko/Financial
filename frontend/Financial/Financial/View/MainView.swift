//
//  MainView.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct MainView: View {
    
    
    var body: some View {
        TabView {
            TransactionListView()
                .tabItem {
                    Image(systemName: "house")
                }
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                }
            CreateTransactionView()
                .tabItem {
                    Image("addIcon")
                }
            GoalsView()
                .tabItem {
                    Image(systemName: "medal")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                }
        }
        .tint(Color("FirstColorGradient"))
        .toolbarBackground(Color("BackroundColor"), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

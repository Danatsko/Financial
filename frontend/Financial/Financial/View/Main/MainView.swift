//
//  MainView.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var appState: AppState
    @State var selectedTab: String = "Home"
    
    let tabs =  ["Home", "Statistics", "Create", "Goals", "Profile"]
    
    init() {
        UITabBar.appearance().isHidden = true
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                TransactionListView()
                    .tag("Home")
                
                StatisticsView()
                    .tag("Statistics")
                
                CreateTransactionView()
                    .tag("Create")
                
                GoalsView()
                    .tag("Goals")
                
                ProfileView()
                    .tag("Profile")
                    .environmentObject(appState)
            }
            VStack {
                Spacer()
                
                HStack {
                    ForEach(tabs, id: \.self) { tab in
                        TabBarItem(tab: tab, selected: $selectedTab)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .padding(.bottom, 20)
                .padding(.horizontal, 10)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}


struct TabBarItem: View {
    
    @State var tab: String
    @Binding var selected: String
    
    let shadowColors: [Color] = [
        Color("ShadowButton").opacity(0.95),
        Color("ShadowButton").opacity(0.78),
        Color("ShadowButton").opacity(0.62),
        Color("ShadowButton").opacity(0.35)
    ]
    
    var body: some View {
        if tab == "Create" {
            Button {
                withAnimation(.easeInOut){
                    selected = tab
                }
            } label: {
                if selected == tab {
                    ZStack {
                        ForEach(shadowColors.indices, id: \.self) { i in
                            Image("AddBtnWithoutShadows")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .shadow(color: shadowColors[i], radius: CGFloat(4 + i * 3))
                                .transition(.opacity)
                                .animation(.none, value: selected)
                        }
                    }
                } else {
                    Image("AddBtnWithoutShadows")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
            }
        } else {
            ZStack {
                Button {
                    withAnimation(.spring()){
                        selected = tab
                    }
                } label: {
                    HStack {
                        Image(systemName: imageForTab())
                            .foregroundStyle(Color("ButtonExpense"))
                        if tab == selected {
                            Text(tab)
                                .font(.custom("Montserrat-SemiBold", size: 15))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .opacity(selected == tab ? 1 : 0.7)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(selected == tab ? Color.white.opacity(0.2) : Color.clear)
            .clipShape(Capsule())
            .foregroundStyle(.white)
            .shadow(color: .white.opacity(selected == tab ? 0.1 : 0), radius: 5)
        }
    }
    
    func imageForTab() -> String {
        switch tab {
        case "Home":
            return "house"
        case "Statistics":
            return "chart.bar"
        case "Create":
            return "addIcon"
        case "Goals":
            return "medal"
        case "Profile":
            return "person"
        default:
            return "exclamationmark.triangle"
        }
    }
}

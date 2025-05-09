//
//  StartView.swift
//  Financial
//
//  Created by KeeR ReeK on 05.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct StartView: View {
    
    @StateObject var navigationService = NavigationServiceStart.shared
    @StateObject var viewModel = RegistrationViewViewModel.shared
    
    var body: some View {
        VStack {
            
            LogoView()
            
            FNButton(text: "login", color: Color.white) {
                navigationService.goToLoginView()
            }
            
            FNButton(text: "createAccount", color: Color("ButtonLoginColor")) {
                navigationService.goToRegistrationView()
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color("BackroundColor"))
        .navigationDestination(for: StartRoute.self) { screen in
            switch screen {
            case .login:
                LoginView(navigationService: navigationService)
            case .registration:
                RegistationView(viewModel: viewModel, navigationService: navigationService)
            case .budgetInput:
                BudgetInputView(viewModel: viewModel)
            }
        }
    }
}

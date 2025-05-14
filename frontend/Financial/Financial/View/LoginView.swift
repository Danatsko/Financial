//
//  LoginView.swift
//  Financial
//
//  Created by KeeR ReeK on 06.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @ObservedObject var navigationService: NavigationServiceStart
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            LogoView()
            
            EmailFieldView(email: $viewModel.email, isValidEmail: $viewModel.isValidEmail) { newEmail in
                viewModel.validateEmail(newEmail)
            }
            
            PasswordFieldView(password: $viewModel.password, isPasswordVisible: $viewModel.isPasswordVisible, isValidPassword: $viewModel.isValidPassword, typeView: "login") {
                newPassword in
                viewModel.validatePassword(newPassword)
            }
            
            FNButton(text: "login", color: Color("ButtonLoginColor")) {
                if await viewModel.login() {
                    appState.isLoggedIn = true
                    navigationService.clearAll()
                }
            }
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
            .disabled(viewModel.isAvaibleLogin())
            .opacity(viewModel.isAvaibleLogin() ? 0.5 : 1.0)
            
            OrDividerView()
            
            HStack {
                Text("noAccount")
                    .font(.custom("Montserrat-SemiBold", size: 14))
                    .foregroundColor(Color("PlaceHolderColor"))
                Button {
                    navigationService.goToRegistrationWithLogin()
                } label: {
                    Text("create")
                        .font(.custom("Montserrat-SemiBold", size: 14))
                        .foregroundColor(Color("ButtonLoginColor"))
                }
            }
            .padding(.top, 30)
            
        }
        .alert("Error", isPresented: $viewModel.isVisibleErrorResponse) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("There was an error on the server. Please try again in a few minutes.")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color("BackroundColor"))
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: Button(action: {
            navigationService.goBack()
        }, label: {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        })
        )
        .onTapGesture {
            UIApplication.shared.dismissKeyboard()
        }
    }
    
}

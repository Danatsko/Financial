//
//  RegistrationView.swift
//  Financial
//
//  Created by KeeR ReeK on 06.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct RegistationView: View {
    
    @StateObject var viewModel: RegistrationViewViewModel
    @ObservedObject var navigationService: NavigationServiceStart
    
    var body: some View {
        
        ScrollView {
            VStack {
                LogoView()
                
                EmailFieldView(email: $viewModel.email, isValidEmail: $viewModel.isValidEmail) { newEmail in
                    viewModel.validateEmail(newEmail)
                }
                
                PasswordFieldView(
                    password: $viewModel.password,
                    isPasswordVisible: $viewModel.isPasswordVisible,
                    isValidPassword: $viewModel.isValidPassword,
                    placeholder: "password", typeView: "registration") { newValue in
                        viewModel.validatePassword(newValue)
                    }
                
                PasswordFieldView(
                    password: $viewModel.confirmPassword,
                    isPasswordVisible: $viewModel.isConfirmPasswordVisible,
                    isValidPassword: $viewModel.isValidConfirmPassword,
                    placeholder: "confirmPassword", typeView: "registration") { newValue in
                        viewModel.validatePassword(newValue)
                    }
                
                
                FNButton(text: "createAccount", color: .white) {
                    navigationService.goToBudgetInputView()
                }
                .frame(height: 55)
                .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))
                .disabled(viewModel.isAvaibleRegistration())
                .opacity(viewModel.isAvaibleRegistration() ? 0.5 : 1.0)
                
                OrDividerView()
                
                
                HStack {
                    Text("accountExists")
                        .font(.custom("Montserrat-SemiBold", size: 14))
                        .foregroundColor(Color("PlaceHolderColor"))
                    Button {
                        navigationService.goToLoginWithRegistration()
                    } label: {
                        Text("login")
                            .font(.custom("Montserrat-SemiBold", size: 14))
                            .foregroundColor(Color("ButtonLoginColor"))
                    }
                }
                .padding(.top, 30)
            }
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


extension UIApplication {
    func dismissKeyboard() {
        if let windowScene = connectedScenes.first as? UIWindowScene {
            windowScene.windows.first { $0.isKeyWindow }?.endEditing(true)
        }
    }
}

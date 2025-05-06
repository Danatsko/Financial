//
//  PasswordFieldView.swift
//  Financial
//
//  Created by KeeR ReeK on 06.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct PasswordFieldView: View {
    @Binding var password: String
    @Binding var isPasswordVisible: Bool
    @Binding var isValidPassword: Bool
    var placeholder: String = "password"
    var typeView: String
    var onPasswordChange: ((String) -> Void)?
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                if isPasswordVisible {
                    TextField(
                        "",
                        text: $password,
                        prompt: Text(placeholder)
                            .foregroundColor(Color("PlaceHolderColor"))
                            .font(.custom("Montserrat-SemiBold", size: 16))
                    )
                    .onChange(of: password) { newValue in
                        onPasswordChange?(newValue)
                    }
                } else {
                    SecureField(
                        "",
                        text: $password,
                        prompt: Text(placeholder)
                            .foregroundColor(Color("PlaceHolderColor"))
                            .font(.custom("Montserrat-SemiBold", size: 16))
                    )
                    .onChange(of: password) { newValue in
                        onPasswordChange?(newValue)
                    }
                    .textContentType(.oneTimeCode)
                }
            }
            .autocapitalization(.none)
            .padding(EdgeInsets(top: 20, leading: 50, bottom: 20, trailing: 50))
            .overlay(
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .padding(20)
                    Spacer()
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                            .padding(20)
                    }
                }
            )
            .background(Color("TextFieldBackround"))
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if !isValidPassword {
                if typeView == "login" {
                    Text("incorrectPassword")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.bottom, 3)
                } else {
                    Text("passwordsNotMatch")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.bottom, 3)
                }
                
            }
        }
    }
}

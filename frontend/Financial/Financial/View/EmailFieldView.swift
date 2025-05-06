//
//  EmailFieldView.swift
//  Financial
//
//  Created by KeeR ReeK on 06.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct EmailFieldView: View {
    @Binding var email: String
    @Binding var isValidEmail: Bool
    var onEmailChange: ((String) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(
                "",
                text: $email,
                prompt: Text("email")
                    .foregroundColor(Color("PlaceHolderColor"))
                    .font(.custom("Montserrat-SemiBold", size: 16))
            )
            .onChange(of: email, perform: { newValue in
                onEmailChange?(newValue)
            })
            .keyboardType(.emailAddress)
            .padding(EdgeInsets(top: 20, leading: 50, bottom: 20, trailing: 20))
            .overlay(
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.gray)
                        .padding(20)
                    Spacer()
                }
            )
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .background(Color("TextFieldBackround"))
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if !isValidEmail {
                Text("incorrectEmail")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

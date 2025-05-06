//
//  BudgetInputView.swift
//  Financial
//
//  Created by KeeR ReeK on 06.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct BudgetInputView: View {
    @StateObject var viewModel: RegistrationViewViewModel
    
    var body: some View {
        VStack {
            Spacer()
            LogoView()
            ZStack(alignment: .topLeading) {
                Image("cards")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 346, height: 340)
                HStack {
                    Text("₴")
                        .padding(.leading, 8)
                        .font(.custom("Montserrat-SemiBold", size: 24))
                    TextField("", text: $viewModel.monthlyBudget,
                              prompt: Text("__________")
                        .foregroundColor(.white)
                        .font(.custom("Montserrat-SemiBold", size: 24))
                    )
                    .keyboardType(.numberPad)
                    .font(.system(size: 24))
                    .onChange(of: viewModel.monthlyBudget) { newValue in
                        if newValue.count > 19 {
                            viewModel.monthlyBudget = String(newValue.prefix(19))
                        } else {
                            viewModel.monthlyBudget = viewModel.formatNumber(newValue)
                        }
                    }
                    
                }
                .foregroundColor(.white)
                .padding(.leading, 16)
                .padding(.top, 100)
                .rotationEffect(.degrees(-8))
            }
            
            Spacer()
            
            FNButton(text: "enterBudget", color: Color("ButtonLoginColor")) {
                
            }
            .disabled(viewModel.isAvaibleBudget())
            .opacity(viewModel.isAvaibleBudget() ? 0.5 : 1.0)
            
            Spacer()
        }
        .alert("Error", isPresented: $viewModel.isVisibleErrorResponse) {
            Button("OK", role: .destructive) {
            }
        } message: {
            Text("There was an error on the server. Please try again in a few minutes.")
        }
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: Button(action: {
        }, label: {
            HStack {
                Image(systemName: "arrow.backward")
                Text("Back")
            }
        })
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color("BackroundColor"))
        .onTapGesture {
            UIApplication.shared.dismissKeyboard()
        }
    }
}

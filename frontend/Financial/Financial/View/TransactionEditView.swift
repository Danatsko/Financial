//
//  TransactionEditView.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct TransactionEditView: View {
    
    @ObservedObject var viewModel: TransactionEditViewModel
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("editing")
                    .font(.custom("Montserrat-Bold", size: 24))
                    .foregroundColor(.white)
                
                ZStack {
                    Color("TextFieldBackround")
                        .edgesIgnoringSafeArea(.all)
                        .cornerRadius(30)
                    
                    CurrencyFieldView(value: $viewModel.amount, formatter: viewModel.formatter)
                        .foregroundColor(.white)
                        .font(.custom("Montserrat-SemiBold", size: 23))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(width: 300)
                        .padding()
                }
                
                TextField("", text: $viewModel.title, prompt:
                            Text("title")
                    .foregroundColor(Color.white)
                    .font(viewModel.customFont)
                )
                .foregroundColor(.white)
                .font(viewModel.customFont)
                .padding()
                .background(Color("TextFieldBackround"))
                .cornerRadius(30)
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $viewModel.descriptionText)
                        .frame(height: 100)
                        .scrollContentBackground(.hidden)
                        .padding()
                        .background(Color("TextFieldBackround"))
                        .foregroundColor(.white)
                        .font(.custom("Montserrat-SemiBold", size: 18))
                        .cornerRadius(30)
                    
                    if viewModel.descriptionText.isEmpty {
                        Text("description")
                            .foregroundColor(.white)
                            .font(.custom("Montserrat-SemiBold", size: 18))
                            .padding(.top, 20)
                            .padding(.leading, 20)
                    }
                }
                
                HStack {
                    Text("category")
                        .foregroundColor(.white)
                        .font(viewModel.customFont)
                        .padding()
                    Spacer()
                    Picker("", selection: $viewModel.pickedCategory) {
                        ForEach(
                            viewModel.selectoryCategory(), id: \.self
                        ) { category in
                            Text(category.localized)
                                .font(viewModel.customFont)
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .tint(.white)
                    .padding()
                }
                .background(Color("TextFieldBackround"))
                .cornerRadius(30)
                
                HStack {
                    Text("paymentMethod")
                        .foregroundColor(.white)
                        .font(viewModel.customFont)
                        .padding()
                    Spacer()
                    Picker("", selection: $viewModel.pickedPayment) {
                        ForEach(
                            viewModel.paymentArray, id: \.self
                        ) { category in
                            Text(category.localized)
                                .font(viewModel.customFont)
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .tint(.white)
                    .padding()
                }
                .background(Color("TextFieldBackround"))
                .cornerRadius(30)
                
                HStack {
                    Text("date")
                        .foregroundColor(.white)
                        .font(viewModel.customFont)
                        .padding()
                    
                    DatePicker("", selection: $viewModel.dateCreate, in: viewModel.minDate...viewModel.maxDate)
                        .padding()
                }
                .background(Color("TextFieldBackround"))
                .cornerRadius(30)
                
                SwipeToConfirmView() {
                    Task {
                        let result: (Bool, String?) = await viewModel.updateTransaction()
                        if !result.0 && result.1 == "logout" {
                            appState.isLoggedIn = false
                            CoreDataManager.shared.deleteUser()
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        viewModel.path.removeLast(viewModel.path.count)
                        viewModel.resetForm()
                    }
                }
                .disabled(!viewModel.isFormValid)
                .opacity(viewModel.isFormValid ? 1.0 : 0.5)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color("BackroundColor"))
        .onTapGesture {
            UIApplication.shared.dismissKeyboard()
        }
    }
}



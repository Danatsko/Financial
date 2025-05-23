//
//  CreateTransactionView.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

import SwiftUI

struct CreateTransactionView: View {

    @StateObject var viewModel = CreateTransactionViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("newTransaction")
                    .font(.custom("Montserrat-Bold", size: 24))
                    .foregroundColor(.white)

                TypeButtonsViewNewTransaction(
                    selectedCategory: $viewModel.type,
                    incomeButtonState: $viewModel.incomeButtonState,
                    costsButtonState: $viewModel.costsButtonState,
                    incomeAction: { viewModel.buttonToggle(isIncomeButton: true) },
                    costsAction: { viewModel.buttonToggle(isIncomeButton: false) }
                )

                TransactionInputFieldsView(viewModel: viewModel)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackroundColor"))
        .onTapGesture {
            UIApplication.shared.dismissKeyboard()
        }
    }
}


struct TransactionInputFieldsView: View {
    @ObservedObject var viewModel: CreateTransactionViewModel
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Color("TextFieldBackround")
                    .edgesIgnoringSafeArea(.all)
                    .cornerRadius(30)

                CurrencyFieldView(value: $viewModel.amount, formatter: viewModel.formatter)
                    .foregroundColor(.white)
                    .font(.custom("Montserrat-SemiBold", size: 23))
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
                        .allowsHitTesting(false)
                }
            }

            HStack {
                Text("category")
                    .foregroundColor(.white)
                    .font(viewModel.customFont)
                    .padding(.leading)
                Spacer()
                Picker("", selection: $viewModel.pickedCategory) {
                    ForEach(
                        viewModel.selectoryCategory(), id: \.self
                    ) { category in
                        Text(LocalizedStringKey(category))
                            .font(viewModel.customFont)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .tint(.white)
                .padding(.trailing)
            }
            .padding(.vertical, 5)
            .background(Color("TextFieldBackround"))
            .cornerRadius(30)

            HStack {
                Text("paymentMethod")
                    .foregroundColor(.white)
                    .font(viewModel.customFont)
                    .padding(.leading)
                Spacer()
                Picker("", selection: $viewModel.pickedPayment) {
                    ForEach(
                        viewModel.paymentArray, id: \.self
                    ) { category in
                        Text(LocalizedStringKey(category))
                            .font(viewModel.customFont)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .tint(.white)
                .padding(.trailing)
            }
            .padding(.vertical, 5)
            .background(Color("TextFieldBackround"))
            .cornerRadius(30)

            HStack {
                Text("date")
                    .foregroundColor(.white)
                    .font(viewModel.customFont)
                    .padding(.leading)

                DatePicker(
                    "",
                    selection: $viewModel.dateCreate,
                    in: viewModel.minDate...viewModel.maxDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .tint(Color.white)
                .padding(.trailing)
            }
             .padding(.vertical, 5)
             .background(Color("TextFieldBackround"))
             .cornerRadius(30)

            
            Button("cleanForm") {
                viewModel.resetForm()
            }
            .foregroundColor(.red)
            .padding(.top)

            SwipeToConfirmView() {
                Task {
                    let result: (Bool, String?) = await viewModel.createTransaction()
                    if !result.0 && result.1 == "logout" {
                        appState.isLoggedIn = false
                        CoreDataManager.shared.deleteUser()
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        viewModel.resetForm()
                    }
                }
            }
            .disabled(!viewModel.isFormValid)
            .opacity(viewModel.isFormValid ? 1.0 : 0.5)

            Spacer()
        }
        .disabled(viewModel.type.isEmpty)
        .opacity(!viewModel.type.isEmpty ? 1 : 0.5)
    }
}

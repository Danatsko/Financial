//
//  EditingProfileView.swift
//  Financial
//
//  Created by KeeR ReeK on 12.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct EditingProfileView: View {
    @Binding var imageName: String
    @StateObject var viewModel = EditingProfileViewViewModel()
    
    var body: some View {
        VStack {
            
            Text("Change Avatar")
                .font(.custom("Montserrat-SemiBold", size: 30))
                .foregroundStyle(.white)
                .frame(alignment: .center)
                .padding()
            
            HStack {
                Text("chooseAvatar")
                    .foregroundColor(.white)
                    .font(.custom("Montserrat-SemiBold", size: 15))
                    .padding()
                Picker("choosePhoto", selection: $imageName) {
                    ForEach(viewModel.availableImages, id: \ .self) { imageName in
                        Text(imageName).tag(imageName)
                    }
                }
                .onChange(of: imageName) { newValue in
                    viewModel.saveImageName(newValue)
                }
                .pickerStyle(MenuPickerStyle())
                .tint(.white)
                
            }
            .background(Color("TextFieldBackround"))
            .cornerRadius(30)
            
            Text("Change data")
                .font(.custom("Montserrat-SemiBold", size: 30))
                .foregroundStyle(.white)
                .frame(alignment: .center)
                .padding()
            
            HStack {
                Text("Change email")
                    .font(.custom("Montserrat-SemiBold", size: 15))
                    .foregroundStyle(.white)
                    .padding()
                Spacer()
            }
            
            EmailFieldView(email: $viewModel.changeEmail, isValidEmail: $viewModel.isValidEmail) { newEmail in
                viewModel.validateEmail(newEmail)
            }
            .padding()
            
            HStack {
                Text("Change monthly budget")
                    .font(.custom("Montserrat-SemiBold", size: 15))
                    .foregroundStyle(.white)
                    .padding()
                Spacer()
            }
            
            HStack {
                Text("₴")
                    .padding(.leading, 8)
                    .font(.custom("Montserrat-SemiBold", size: 24))
                TextField("", text: $viewModel.changeMonthBudget)
                    .padding()
                    .keyboardType(.numberPad)
                    .font(.system(size: 24))
                    .background(Color("TextFieldBackround"))
                    .cornerRadius(30)
                
                    .onChange(of: viewModel.changeMonthBudget) { newValue in
                        if newValue.count > 19 {
                            viewModel.changeMonthBudget = String(newValue.prefix(19))
                        } else {
                            viewModel.changeMonthBudget = viewModel.formatNumber(newValue)
                        }
                    }
                
            }
            .padding()
            .foregroundColor(.white)
            
            Button {
                Task {
                    if await viewModel.changeDataUser() {
                        viewModel.changeEmail = ""
                        viewModel.changeMonthBudget = ""
                    }
                }
            } label: {
                Text("Confirm data changes")
                    .foregroundColor(.white)
                    .font(.custom("Montserrat-SemiBold", size: 15))
                    .padding()
            }
            .disabled(!viewModel.isChangeAvailable())
            .opacity(viewModel.isChangeAvailable() ? 1 : 0.5)
            .background(Color("TextFieldBackround"))
            .cornerRadius(30)
            .padding()
        }
        .onTapGesture {
            UIApplication.shared.dismissKeyboard()
        }
        
    }
}

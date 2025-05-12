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
        HStack {
            Text("chooseAvatar")
                .foregroundColor(.white)
                .font(.custom("Montserrat-SemiBold", size: 20))
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
            .padding()
        }
        .background(Color("TextFieldBackround"))
        .cornerRadius(30)
    }
}

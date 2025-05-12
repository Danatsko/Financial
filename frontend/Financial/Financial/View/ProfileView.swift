//
//  ProfileView.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewViewModel()
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    Image("avatar")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .clipShape(Circle())
                    Image(viewModel.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .clipShape(Circle())
                }
                Spacer()
                
                VStack(alignment: .leading) {
                    ProfileButton(imageName: "editingProfile", title: "editingProfile") {
                        viewModel.showEditProfile = true
                    }
                    ProfileButton(imageName: "settings", title: "settings") {
                        viewModel.showSettings = true
                    }
                    ProfileButton(imageName: "question", title: "help") {
                        viewModel.showHelp = true
                    }
                    
                    HStack {
                        Spacer()
                        Button {
                            viewModel.showAlert = true
                        } label: {
                            Text("logOut")
                                .font(.custom("Montserrat-SemiBold", size: 20))
                                .foregroundColor(.red)
                        }
                        .alert("warning", isPresented: $viewModel.showAlert) {
                            Button("cancel", role: .cancel) {}
                            Button("confirm", role: .destructive) {
                                Task {
                                    if await viewModel.logoutApi() {
                                        if await viewModel.logout() {
                                            appState.isLoggedIn = false
                                        }
                                    }
                                    CoreDataManager.shared.deleteUser()
                                }
                                appState.isLoggedIn = false
                                CoreDataManager.shared.deleteUser()
                            }
                        } message: {
                            Text("confirmLogOut")
                        }
                        Spacer()
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .background(Color("TextFieldBackround"))
                .cornerRadius(30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color("BackroundColor"))
        .onTapGesture {
            UIApplication.shared.dismissKeyboard()
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView()
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $viewModel.showEditProfile) {
            EditingProfileView(
                imageName: $viewModel.imageName,
                viewModel: EditingProfileViewViewModel()
            )
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $viewModel.showHelp) {
            HelpView()
        }
    }
}

struct ProfileButton: View {
    let imageName: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(imageName)
                    .resizable()
                    .frame(width: 50, height: 50)
                Text(title)
                    .font(.custom("Montserrat-SemiBold", size: 24))
            }
            .foregroundColor(.white)
        }
        .padding(12)
    }
}

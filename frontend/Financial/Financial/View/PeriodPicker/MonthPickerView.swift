//
//  MonthPickerView.swift
//  Financial
//
//  Created by KeeR ReeK on 11.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct MonthPickerView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    @ObservedObject var navigationService = NavigationServiceStatistics.shared
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Choose month")
                .foregroundColor(.white)
                .font(.custom("Montserrat-Bold", size: 30))
            
            
            Picker("Choose month", selection: $viewModel.selectedMonth) {
                ForEach(viewModel.months, id:\.self) { year in
                    Text("\(year)").tag(year)
                }
            }
            .pickerStyle(.wheel)
            .padding(.bottom, 15)
            
            
            if viewModel.typePeriod == .month {
                Button {
                    print(viewModel.selectedMonth)
                    Task {
                        let result: (Bool, String?) = await viewModel.getStatistics(period: viewModel.typePeriod)
                        if !result.0 && result.1 == "logout" {
                            appState.isLoggedIn = false
                            CoreDataManager.shared.deleteUser()
                        }
                    }
                    viewModel.isDateSelected.toggle()
                    navigationService.goBack()
                } label: {
                    Text("Done")
                        .font(.custom("Montserrat-SemiBold", size: 20))
                        .padding()
                        .background(Color.buttonLogin)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
            } else if viewModel.typePeriod == .week {
                Button {
                    print(viewModel.selectedMonth)
                    navigationService.goToWeekPicker()
                } label: {
                    Text("Next")
                        .font(.custom("Montserrat-SemiBold", size: 20))
                        .padding()
                        .background(Color.buttonLogin)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
            } else {
                Button {
                    print(viewModel.selectedMonth)
                    navigationService.goToDayPicker()
                } label: {
                    Text("Next")
                        .font(.custom("Montserrat-SemiBold", size: 20))
                        .padding()
                        .background(Color.buttonLogin)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
            }
            
        }
        .toolbar(.hidden, for: .tabBar)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackroundColor"))
    }
}

//
//  DayPickerView.swift
//  Financial
//
//  Created by KeeR ReeK on 11.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct DayPickerView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    @ObservedObject var navigationService = NavigationServiceStatistics.shared
    @EnvironmentObject var appState: AppState
    
    
    var body: some View {
        
        VStack(spacing: 15) {
            Text("Choose a day")
                .foregroundColor(.white)
                .font(.custom("Montserrat-Bold", size: 30))
            
            let (month, _) = viewModel.monthNumber(from: viewModel.selectedMonth, year: viewModel.selectedYear)
            
            if let startDate = viewModel.getStartDate(year: viewModel.selectedYear, month: month ?? 0),
               let endDate = viewModel.getEndDate(year: viewModel.selectedYear, month: month ?? 0) {
                
                DatePicker("Оберіть день", selection: $viewModel.selectedDay, in: startDate...endDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.bottom, 15)
                
            } else {
                Text("Invalid month or year")
            }
            
            Button {
                print(viewModel.selectedDay)
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
                Text("done")
                    .font(.custom("Montserrat-SemiBold", size: 20))
                    .padding()
                    .background(Color.buttonLogin)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            
            
            
            
            
        }
        .toolbar(.hidden, for: .tabBar)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackroundColor"))
    }
}

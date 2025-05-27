//
//  YearPickerView.swift
//  Financial
//
//  Created by KeeR ReeK on 11.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct YearPickerView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    @ObservedObject var navigationService = NavigationServiceStatistics.shared
    
    var body: some View {
        VStack(spacing: 15) {
                Text("Choose year")
                    .foregroundColor(.white)
                    .font(.custom("Montserrat-Bold", size: 30))

                
                Picker("Choose year", selection: $viewModel.selectedYear) {
                    ForEach(viewModel.years, id:\.self) { year in
                        Text("\(year)").tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .padding(.bottom, 15)
                
                Button {
                    print(viewModel.selectedYear)
                    navigationService.goToMonthPicker()
                } label: {
                    Text("Next")
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


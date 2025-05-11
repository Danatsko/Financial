//
//  StatisticsView.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct StatisticsView: View {
    @StateObject var viewModel = StatisticsViewModel()
    
    @ObservedObject var navigationService = NavigationServiceStatistics.shared
    
    
    var body: some View {
        NavigationStack(path: $navigationService.statisticsPath) {
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Text("statistics")
                            .font(.custom("Montserrat-Bold", size: 24))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    HStack {
                        if viewModel.isDateSelected {
                            VStack {
                                TypeButtonsViewStatistics(viewModel: viewModel)
                            }
                        }
                        VStack {
                            if viewModel.isDateSelected {
                                Text("Обраний період")
                                    .foregroundColor(.white)
                                    .font(.custom("Montserrat-Bold", size: 20))
                                    .padding()
                                
                                if viewModel.typePeriod == .day {
                                    Text("\(viewModel.getFormattedDayDate())")
                                        .foregroundColor(.white)
                                        .font(.custom("Montserrat-SemiBold", size: 18))
                                        .padding()
                                } else if viewModel.typePeriod == .week {
                                    Text("\(viewModel.getFormattedWeekDate(at: 0)) - \(viewModel.getFormattedWeekDate(at: 1))")
                                        .foregroundColor(.white)
                                        .font(.custom("Montserrat-SemiBold", size: 15))
                                        .padding()
                                } else {
                                    Text("\(viewModel.selectedMonth) \(viewModel.selectedYear)")
                                        .foregroundColor(.white)
                                        .font(.custom("Montserrat-SemiBold", size: 18))
                                        .padding()
                                }
                                
                                Button {
                                    viewModel.isDateSelected.toggle()
                                } label: {
                                    Text("Змінити період")
                                }
                                
                                
                            } else {
                                HStack(spacing: 16) {
                                    HStack {
                                        Button("День") {
                                            viewModel.typePeriod = PeriodEnum.day
                                        }
                                        .foregroundColor(viewModel.typePeriod == PeriodEnum.day ? Color("ButtonIncome") : .white)
                                        
                                        Button("Тиждень") {
                                            viewModel.typePeriod = .week
                                        }
                                        .foregroundColor(viewModel.typePeriod == PeriodEnum.week ? Color("ButtonIncome") : .white)
                                        
                                        Button("Місяць") {
                                            viewModel.typePeriod = .month
                                        }
                                        .foregroundColor(viewModel.typePeriod == PeriodEnum.month ? Color("ButtonIncome") : .white)
                                    }
                                    .font(.custom("Montserrat-Medium", size: 13))
                                }
                                
                                Button {
                                    navigationService.goToYearPicker()
                                } label: {
                                    Text("Обрати період")
                                        .padding()
                                        .font(.custom("Montserrat-Bold", size: 13))
                                        .foregroundColor(.white)
                                        .background(Color.gray)
                                        .cornerRadius(15)
                                }
                            }
                        }
                    }
                    
                    if viewModel.isDateSelected {
                        if viewModel.isTypeSelected {
                            HStack {
                                Text("analytics")
                                    .font(.custom("Montserrat-Bold", size: 24))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            StatisticsCharts(
                                data: viewModel.selectoryType(),
                                typePeriod: $viewModel.typePeriod
                            )
                            
                            if viewModel.type == "costs" {
                                CategoryStatistics(
                                    viewModel: viewModel
                                )
                            } else if viewModel.type == "incomes" {
                                CategoryStatistics(
                                    viewModel: viewModel
                                )
                            }
                            
                            Spacer()
                        } else {
                            Text("Оберіть тип")
                        }
                    } else {
                        Text("Оберіть дату")
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color("BackroundColor"))
            .navigationDestination(for: StatisticsRoute.self) { route in
                switch route {
                case .selectedDateStat:
                    YearPickerView(viewModel: viewModel)
                case .monthPicker:
                    MonthPickerView(viewModel: viewModel)
                case .weekPicker:
                    WeekPickerView(viewModel: viewModel)
                case .dayPicker:
                    DayPickerView(viewModel: viewModel)
                default:
                    MainView()
                }
            }
        }
    }
}

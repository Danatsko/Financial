//
//  WeekPickerView.swift
//  Financial
//
//  Created by KeeR ReeK on 11.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct WeekPickerView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    @ObservedObject var navigationService = NavigationServiceStatistics.shared
    @EnvironmentObject var appState: AppState

    var body: some View {
        
        VStack(spacing: 15) {
            Text("Choose week")
                .foregroundColor(.white)
                .font(.custom("Montserrat-Bold", size: 30))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(getWeeks(for: getDate()), id: \.self) { weekDates in
                        let firstDate = weekDates.first ?? Date()
                        let lastDate = weekDates.last ?? Date()
                        let isSelected = viewModel.selectedWeek[0] == firstDate

                        WeekCellView(
                            firstDate: firstDate,
                            lastDate: lastDate,
                            isSelected: isSelected,
                            onTap: {
                                viewModel.selectedWeek[0] = firstDate
                                viewModel.selectedWeek[1] = lastDate
                            },
                            weekFormatter: weekFormatter
                        )
                    }
                }
            }
            
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
        }
        .padding()
    }
    
    func getDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = viewModel.selectedYear
        let (month, _) = viewModel.monthNumber(from: viewModel.selectedMonth, year: viewModel.selectedYear)
        dateComponents.month = month
        dateComponents.day = 1
        guard let date = Calendar.current.date(from: dateComponents) else {
            print("Could not create a date from DateComponents")
            return Date()
        }
        return date
    }

    func getWeeks(for date: Date) -> [[Date]] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: date) else { return [] }
        var weeks: [[Date]] = []
        var weekStartDate = monthInterval.start

        while weekStartDate < monthInterval.end {
            guard let weekInterval = Calendar.current.dateInterval(of: .weekOfMonth, for: weekStartDate) else { break }
            weeks.append(dateRange(from: weekInterval))
            weekStartDate = Calendar.current.date(byAdding: .weekOfMonth, value: 1, to: weekStartDate)!
        }

        return weeks
    }

    func dateRange(from interval: DateInterval) -> [Date] {
        var dates: [Date] = []
        var currentDate = interval.start

        while currentDate < interval.end {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return dates
    }

    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM<x_bin_642>"
        return formatter
    }

    private var weekFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter
    }
}


struct WeekCellView: View {
    let firstDate: Date
    let lastDate: Date
    let isSelected: Bool
    let onTap: () -> Void
    let weekFormatter: DateFormatter

    var body: some View {
        VStack {
            Text("\(weekFormatter.string(from: firstDate)) - \(weekFormatter.string(from: lastDate))")
                .padding()
                .background(isSelected ? Color.blue : Color.gray)
                .cornerRadius(10)
                .onTapGesture {
                    onTap()
                }
        }
    }
}

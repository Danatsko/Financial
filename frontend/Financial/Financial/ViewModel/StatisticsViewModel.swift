//
//  StatisticsViewModel.swift
//  Financial
//
//  Created by KeeR ReeK on 11.05.2025.
//  Copyright (c) 2025 Financial

import Foundation


@MainActor
class StatisticsViewModel: ObservableObject {
    
    @Published var amountIncomes: Double = 0
    @Published var amountCosts: Double = 0
    @Published var dictionaryChartsIncomes: [String: Double] = [:]
    @Published var dictionaryChartsCosts: [String: Double] = [:]
    @Published var typePeriod: PeriodEnum = .day
    @Published var isDateSelected: Bool = false
    @Published var dateStatistics: Date = Date()
    @Published var selectedYear: Int = 2020
    @Published var selectedMonth: String = "Січень"
    @Published var selectedDay = Date()
    @Published var selectedWeek: [Date] = [Date(), Date()]
    @Published var years: [Int] = []
    @Published var incomeButtonState: Bool = false
    @Published var costsButtonState: Bool = false
    @Published var type: String = ""
    @Published var isTypeSelected = false
    @Published var displayableCategoriesIncomes: [DisplayCategoryIncomesInfo] = []
    @Published var displayableCategoriesCosts: [DisplayCategoryCostsInfo] = []
    @Published var arrayTransactionApi: [TransactionApi] = []
    @Published var categoryName: String = ""
    
    
    
    @Published var months: [String] = [
        "Січень", "Лютий", "Березень", "Квітень", "Травень", "Червень",
        "Липень", "Серпень", "Вересень", "Жовтень", "Листопад", "Грудень"
    ]
    
    init() {
        years = Array(yearInDate()...Calendar.current.component(.year, from: Date()))
    }
    
    func yearInDate() -> Int {
        let date = CoreDataManager.shared.getCreatinDate() ?? Date()
        let calendar = Calendar.current
        let displayDate = calendar.component(.year, from: date)
        selectedYear = displayDate
        return displayDate
    }
    
    func buttonToggle(isIncomeButton income: Bool) {
        if income {
            incomeButtonState = true
            costsButtonState = false
            type = "incomes"
            isTypeSelected = true
        } else {
            incomeButtonState = false
            costsButtonState = true
            type = "costs"
            isTypeSelected = true
        }
        print(type)
    }
    
    func selectoryType() -> [String: Double] {
        isTypeSelected ? (type == "incomes" ? dictionaryChartsIncomes : dictionaryChartsCosts) : [:]
    }
    
    func getFormattedDayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: selectedDay)
    }
    
    func getFormattedWeekDate(at index: Int) -> String {
        guard selectedWeek.indices.contains(index) else {
            return "—"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: selectedWeek[index])
    }
    
    func monthNumber(from monthName: String, year: Int) -> (Int?, Date?) {
        let calendar = Calendar.current
        let monthNumber: Int?
        
        switch monthName {
        case "Січень": monthNumber = 1
        case "Лютий": monthNumber = 2
        case "Березень": monthNumber = 3
        case "Квітень": monthNumber = 4
        case "Травень": monthNumber = 5
        case "Червень": monthNumber = 6
        case "Липень": monthNumber = 7
        case "Серпень": monthNumber = 8
        case "Вересень": monthNumber = 9
        case "Жовтень": monthNumber = 10
        case "Листопад": monthNumber = 11
        case "Грудень": monthNumber = 12
        default: monthNumber = nil
        }
        
        guard let month = monthNumber else {
            print("Неправильна назва місяця: \(monthName)")
            return (nil, nil)
        }
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = 1
        
        guard let date = calendar.date(from: dateComponents) else {
            print("Не вдалося створити дату з DateComponents")
            return (nil, nil)
        }
        
        print("monthNumber успішно заробив і \(date)")
        return (calendar.component(.month, from: date), date)
    }
    
    
    func getStatistics(period: PeriodEnum) async -> (Bool, String?) {
        do {
            let startDate: Date
            let endDate: Date
            switch period {
            case .day:
                let startTimeDate = Calendar.current.startOfDay(for: selectedDay)
                let startOfNextDay = Calendar.current.date(byAdding: .day, value: 1, to: startTimeDate)!
                startDate = startTimeDate
                endDate = Calendar.current.date(byAdding: .second, value: -1, to: startOfNextDay)!
            case .week:
                guard selectedWeek.count == 2 else { return (false, nil) }
                startDate = Calendar.current.startOfDay(for: selectedWeek[0])
                let endOfDayForLastDayOfWeek = Calendar.current.date(byAdding: .second, value: -1, to: Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: selectedWeek[1])!))!
                endDate = endOfDayForLastDayOfWeek
            case .month:
                let (_, dateForMonth) = monthNumber(from: selectedMonth, year: selectedYear)
                guard let firstDayOfMonth = dateForMonth else { return (false, nil) }
                startDate = Calendar.current.startOfDay(for: firstDayOfMonth)
                let startOfNextMonth = Calendar.current.date(byAdding: .month, value: 1, to: firstDayOfMonth)!
                endDate = Calendar.current.date(byAdding: .second, value: -1, to: startOfNextMonth)!
            }
            
            let response = try await ApiService.shared.getStatistics(startData: startDate, endData: endDate)
            
            
            dictionaryChartsIncomes = response.timeData.incomes
            dictionaryChartsCosts = response.timeData.costs
            amountIncomes = response.typeData.incomes.totalAmount
            amountCosts = response.typeData.costs.totalAmount
            
            let incomesCategoriesDict = response.typeData.incomes.categories
            displayableCategoriesIncomes = transformCategoriesIncomes(incomesCategoriesDict)
            let costsCategoriesDict = response.typeData.costs.categories
            displayableCategoriesCosts = transformCategoriesCosts(costsCategoriesDict)
            
            return (true, nil)
        } catch let error as NetworkError {
            if case .refreshFailed = error {
                return (false, "logout")
            }
        } catch {
            print(error)
            return (false, nil)
        }
        return (false, nil)
    }
    
    func getStartDate(year: Int, month: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = 1
        return Calendar.current.date(from: dateComponents)
    }
    
    func getEndDate(year: Int, month: Int) -> Date? {
        guard let startDate = getStartDate(year: year, month: month),
              let range = Calendar.current.range(of: .day, in: .month, for: startDate) else { return nil }
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = range.count
        return Calendar.current.date(from: dateComponents)
    }
    
    func lastDayOfMonth(from date: Date) -> Date {
        let calendar = Calendar.current
        
        guard let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: date),
              let lastDay = calendar.date(byAdding: .day, value: -1, to: startOfNextMonth) else {
            return Date()
        }
        
        return lastDay
    }
    
    
    func getWeeksOfMonths(year: Int, month: Int) -> [(startDate: Date, endDate: Date)]? {
        let calendar = Calendar.current
        var dateComponents = DateComponents(year: year, month: month, day: 1)
        guard let firstDayOfMonth = calendar.date(from: dateComponents) else { return nil }
        
        let range = calendar.range(of: .weekOfMonth, in: .month, for: firstDayOfMonth)!
        var weeks: [(startDate: Date, endDate: Date)] = []
        
        for weekOfMonth in range {
            dateComponents.weekOfMonth = weekOfMonth
            dateComponents.weekday = 2
            
            guard let startDate = calendar.date(from: dateComponents) else { continue }
            
            dateComponents.weekday = 1
            
            guard let endDate = calendar.date(from: dateComponents) else { continue }
            
            weeks.append((startDate: startDate, endDate: endDate))
        }
        
        return weeks
    }
    
    func transformCategoriesIncomes(_ serverCategories: [String: CategoryInfo]) -> [DisplayCategoryIncomesInfo] {
        return serverCategories.map { (key, categoryInfo) in
            let appCategoryType = AppCategoryTypeIncomes.fromServerKey(key)
            let localizedName = appCategoryType.localizedName
            
            return DisplayCategoryIncomesInfo(
                id: key,
                appCategoryType: appCategoryType,
                localizedName: localizedName,
                percentage: categoryInfo.percentage,
                transactions: categoryInfo.transactions
            )
        }.sorted { $0.localizedName < $1.localizedName }
    }
    
    func transformCategoriesCosts(_ serverCategories: [String: CategoryInfo]) -> [DisplayCategoryCostsInfo] {
        return serverCategories.map { (key, categoryInfo) in
            let appCategoryType = AppCategoryTypeCosts.fromServerKey(key)
            let localizedName = appCategoryType.localizedName
            
            return DisplayCategoryCostsInfo(
                id: key,
                appCategoryType: appCategoryType,
                localizedName: localizedName,
                percentage: categoryInfo.percentage,
                transactions: categoryInfo.transactions
            )
        }.sorted { $0.localizedName < $1.localizedName }
    }
}


enum PeriodEnum {
    case day
    case week
    case month
}


struct DisplayCategoryCostsInfo: Identifiable {
    let id: String
    
    let appCategoryType: AppCategoryTypeCosts
    
    let localizedName: String
    
    let percentage: Double
    let transactions: [TransactionApi]
}

struct DisplayCategoryIncomesInfo: Identifiable {
    let id: String
    
    let appCategoryType: AppCategoryTypeIncomes
    
    let localizedName: String
    
    let percentage: Double
    let transactions: [TransactionApi]
}

//
//  NavigationStatisticsManager.swift
//  Financial
//
//  Created by KeeR ReeK on 11.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

enum StatisticsRoute: Hashable {
    case allType(String)
    case categoryStat(type: String, category: String)
    case selectedDateStat
    case monthPicker
    case weekPicker
    case dayPicker
}

final class NavigationServiceStatistics: ObservableObject {
    static let shared = NavigationServiceStatistics()
    
    @Published var statisticsPath = NavigationPath()
    
    private init() {}
    
    func goToStatisticsAllTypes(type: String) {
        statisticsPath.append(StatisticsRoute.allType(type))
    }
    
    func goToStatisticsCategoryStat(type: String, category: String) {
        statisticsPath.append(StatisticsRoute.categoryStat(type: type, category: category))
    }
    
    func goToYearPicker() {
        statisticsPath.append(StatisticsRoute.selectedDateStat)
    }
    
    func goToMonthPicker() {
        statisticsPath.append(StatisticsRoute.monthPicker)
    }
    
    func goToWeekPicker() {
        statisticsPath.append(StatisticsRoute.weekPicker)
    }
    
    func goToDayPicker() {
        statisticsPath.append(StatisticsRoute.dayPicker)
    }
    
    func goBack() {
        statisticsPath.removeLast(statisticsPath.count)
    }
}

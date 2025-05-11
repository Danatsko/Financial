//
//  GoalsViewModel.swift
//  Financial
//
//  Created by KeeR ReeK on 11.05.2025.
//  Copyright (c) 2025 Financial

import Foundation

class GoalsViewModel: ObservableObject {

    func сalculatePercentAchievement(count: Int) -> Double {
        switch count {
        case 0...99:
            return Double(count) / 100
        case 100...999:
            return Double(count) / 1000
        case 1000...9999:
            return Double(count) / 10000
        case 10000...99999:
            return Double(count) / 100000
        default:
            return 0
        }
    }
    
    func calculateGoal(count: Int) -> Int {
        switch count {
        case ...99:
            return 100
        case ...999:
            return 1000
        case ...9999:
            return 10000
        case ...99999:
            return 100000
        default:
            return 0
        }
    }
}

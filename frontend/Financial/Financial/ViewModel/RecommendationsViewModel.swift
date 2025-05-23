//
//  RecommendationsViewModel.swift
//  Financial
//
//  Created by KeeR ReeK on 19.05.2025.
//  Copyright (c) 2025 Financial

import Foundation
import AnyCodable

class RecommendationsViewModel: ObservableObject {
    @Published var messages: [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func fetchAndProcessRecommendations(jsonData: Data) {
        isLoading = true
        errorMessage = nil
        messages = []
        
        do {
            let response = try JSONDecoder().decode(RecommendationsServerResponse.self, from: jsonData)
            var generatedMessages: [String] = []
            
            for item in response.recommendations {
                let data = item.data
                
                switch item.status {
                case "no_transactions_for_type":
                    if let type = data["types"]?.value as? String,
                       let month = data["month"]?.value as? String {
                        if type == "costs" {
                            generatedMessages.append(.localizedFormat("user.noActivity.costs", formartType(type), formatMonth(month)))
                        } else {
                            generatedMessages.append(.localizedFormat("user.noActivity.incomes", formartType(type), formatMonth(month)))
                        }
                    }

                case "lowest_sum_category_for_type", "highest_sum_category_for_type":
                    if let type = data["types"]?.value as? String,
                       let categories = data["categories"]?.value as? [String],
                       let sum = data["sum"]?.value as? Double,
                       let month = data["month"]?.value as? String {
                        let typeText = (type == "costs") ? "expenses" : "income"
                        let label = item.status.contains("lowest") ? "Lowest" : "Highest"
                        let cats = categories.joined(separator: ", ")
                        generatedMessages.append(.localizedFormat("user.categoryTotal", label, typeText, formartType(type), formatMonth(month), cats, sum))
                    }

                case "lowest_count_category_for_type", "highest_count_category_for_type":
                    if let type = data["types"]?.value as? String,
                       let categories = data["categories"]?.value as? [String],
                       let count = data["count"]?.value as? Int,
                       let month = data["month"]?.value as? String {
                        let label = item.status.contains("lowest") ? "Lowest" : "Highest"
                        let cats = categories.joined(separator: ", ")
                        generatedMessages.append(.localizedFormat("user.categoryCount", label, formartType(type), formatMonth(month), cats, count))
                    }

                case "no_activity_in_category_last_month":
                    if let type = data["types"]?.value as? String,
                       let categories = data["categories"]?.value as? [String],
                       let month = data["month"]?.value as? String {
                        let cats = categories.joined(separator: ", ")
                        generatedMessages.append(.localizedFormat("user.noCategoryActivity", formatMonth(month), cats, formartType(type)))
                    }

                case "budget_exceeded_last_month":
                    if let budget = data["budget_amount"]?.value as? Double,
                       let spent = data["total_spent"]?.value as? Double,
                       let excess = data["excess_amount"]?.value as? Double,
                       let month = data["month"]?.value as? String {
                        generatedMessages.append(.localizedFormat("user.budgetExceeded", budget, formatMonth(month), spent, excess))
                    }

                case "budget_within_limit_last_month":
                    if let budget = data["budget_amount"]?.value as? Double,
                       let spent = data["total_spent"]?.value as? Double,
                       let remaining = data["remaining_amount"]?.value as? Double,
                       let month = data["month"]?.value as? String {
                        generatedMessages.append(.localizedFormat("user.budgetWithinLimit", budget, formatMonth(month), spent, remaining))
                    }

                default:
                    generatedMessages.append(.localizedFormat("user.unknownRecommendation", item.status))
                }
            }
            
            DispatchQueue.main.async {
                self.messages = generatedMessages
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error during decoding: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func formartType(_ type: String) -> String {
        if type == "costs" {
            return String.localizedFormat("type.costs")
        } else {
            return String.localizedFormat("type.incomes")
        }
    }
    
    private func formatMonth(_ monthString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        if let date = formatter.date(from: monthString) {
            formatter.dateFormat = "LLLL yyyy"
            return formatter.string(from: date)
        }
        return monthString
    }
}


extension String {
    static func localizedFormat(_ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String(format: format, arguments: args)
    }
}

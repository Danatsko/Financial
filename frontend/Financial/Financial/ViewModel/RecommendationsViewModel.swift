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
                        generatedMessages.append("Unfortunately, you have no transactions of type \"\(type)\" for \(month).")
                    }
                    
                case "lowest_sum_category_for_type", "highest_sum_category_for_type":
                    if let type = data["types"]?.value as? String,
                       let categories = data["categories"]?.value as? [String],
                       let sum = data["sum"]?.value as? Double,
                       let month = data["month"]?.value as? String {
                        let typeText = (type == "costs") ? "expenses" : "income"
                        let label = item.status.contains("lowest") ? "Lowest" : "Highest"
                        let cats = categories.joined(separator: ", ")
                        generatedMessages.append("\(label) \(typeText) for type \"\(type)\" in \(formatMonth(month)) were in category \"\(cats)\" totaling \(String(format: "%.2f", sum)).")
                    }
                    
                case "lowest_count_category_for_type", "highest_count_category_for_type":
                    if let type = data["types"]?.value as? String,
                       let categories = data["categories"]?.value as? [String],
                       let count = data["count"]?.value as? Int,
                       let month = data["month"]?.value as? String {
                        let label = item.status.contains("lowest") ? "Lowest" : "Highest"
                        let cats = categories.joined(separator: ", ")
                        generatedMessages.append("\(label) number of transactions for type \"\(type)\" in \(formatMonth(month)) was in category \"\(cats)\" with a total of \(count).")
                    }
                    
                case "no_activity_in_category_last_month":
                    if let type = data["types"]?.value as? String,
                       let categories = data["categories"]?.value as? [String],
                       let month = data["month"]?.value as? String {
                        let cats = categories.joined(separator: ", ")
                        generatedMessages.append("You had no activity in the following categories during \(formatMonth(month)): \(cats) (for type \"\(type)\").")
                    }
                    
                case "budget_exceeded_last_month":
                    if let budget = data["budget_amount"]?.value as? Double,
                       let spent = data["total_spent"]?.value as? Double,
                       let excess = data["excess_amount"]?.value as? Double,
                       let month = data["month"]?.value as? String {
                        generatedMessages.append("Warning! Your monthly budget (\(String(format: "%.2f", budget))) was exceeded in \(formatMonth(month)). You spent \(String(format: "%.2f", spent)), which is \(String(format: "%.2f", excess)) over the budget.")
                    }
                    
                case "budget_within_limit_last_month":
                    if let budget = data["budget_amount"]?.value as? Double,
                       let spent = data["total_spent"]?.value as? Double,
                       let remaining = data["remaining_amount"]?.value as? Double,
                       let month = data["month"]?.value as? String {
                        generatedMessages.append("Great job! Your monthly budget (\(String(format: "%.2f", budget))) for \(formatMonth(month)) was not exceeded. You spent \(String(format: "%.2f", spent)), with \(String(format: "%.2f", remaining)) remaining.")
                    }
                    
                default:
                    generatedMessages.append("Received unknown recommendation: \(item.status).")
                }
            }
            
            DispatchQueue.main.async {
                self.messages = generatedMessages
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Помилка при декодуванні: \(error.localizedDescription)"
                self.isLoading = false
            }
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

//
//  ApiService.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import Foundation

struct AchievementsResponseWrapper: Decodable {
    let achievements: AchievementsResponse
}

struct AchievementsResponse: Decodable {
    let costs: [String: Int]
    let incomes: [String: Int]
}

struct FinanceResponse: Decodable {
    
    let timeData: TimeData
    let typeData: TypeData
    let detail: String?
    
    enum CodingKeys: String, CodingKey {
        case timeData = "time_data"
        case typeData = "type_data"
        case detail
    }
}

struct TimeData: Decodable {
    let costs: [String: Double]
    let incomes: [String: Double]
}

struct TypeData: Decodable {
    let costs: CategoryData
    let incomes: CategoryData
}

struct CategoryData: Decodable {
    let totalAmount: Double
    let categories: [String: CategoryInfo]
    
    enum CodingKeys: String, CodingKey {
        case totalAmount = "total_amount"
        case categories
    }
}

struct CategoryInfo: Decodable {
    let percentage: Double
    let transactions: [TransactionApi]
}

struct TransactionApi: Decodable {
    let id: Int
    let userId: Int
    let type: String
    let amount: Double
    let title: String
    let paymentMethod: String
    let description: String
    let category: String
    let creationDate: String

    enum CodingKeys: String, CodingKey {
        case id, type, amount, title, description, category
        case userId = "user_id"
        case paymentMethod = "payment_method"
        case creationDate = "creation_date"
    }
}

struct UserResponse: Decodable {
    let accessToken: String?
    let refreshToken: String?
}

struct UserResponseWrapper: Decodable {
    let user: UserResponseGetUser
}

struct UserResponseGetUser: Decodable {
    let id: Int
    let username: String
    let email: String
    let balance: Double
    let monthlyBudget: Int
    let dateJoined: String
}

struct TransactionResponseWrapper: Decodable {
    let transactions: [TransactionResponseGetTransaction]
}

struct TransactionResponseGetTransaction: Decodable {
    let id: Int
    let type: String
    let amount: Double
    let title: String
    let paymentMethod: String
    let description: String
    let category: String
    let creationDate: String
}

final class ApiService {
    
    static let shared = ApiService()
    
    private init() {}
    
    // MARK: USER
    
    func register(username: String, email: String, password: String, balance: String, monthly_budget: String) async throws {
        guard let url = URL(string: "http://127.0.0.1:8000/api/users/registration/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "username": username,
            "email": email,
            "password": password,
            "balance": balance,
            "monthly_budget": monthly_budget
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, _) = try await NetworkService.shared.performRequest(request, requiresAuth: false)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodeUser = try decoder.decode(UserResponse.self, from: data)
            
            KeychainService.standard.saveAccessToken(token: decodeUser.accessToken ?? nil)
            KeychainService.standard.saveRefreshToken(token: decodeUser.refreshToken ?? nil)
            
        } catch {
            print("❌ Error: \(error)")
            throw error
        }
    }
    
    func login(email: String, password: String) async throws {
        guard let url = URL(string: "http://127.0.0.1:8000/api/users/login/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, _) = try await NetworkService.shared.performRequest(request, requiresAuth: false)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodeUser = try decoder.decode(UserResponse.self, from: data)
            
            KeychainService.standard.saveAccessToken(token: decodeUser.accessToken ?? "")
            KeychainService.standard.saveRefreshToken(token: decodeUser.refreshToken ?? "")
            
        } catch {
            throw error
        }
    }
    
    func getUserInfo() async throws -> Bool {
        guard let url = URL(string: "http://127.0.0.1:8000/api/users/me/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await NetworkService.shared.performRequest(request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodeUser = try decoder.decode(UserResponseWrapper.self, from: data)
            
            if let date = stringToDate(decodeUser.user.dateJoined) {
                print("decodeUserDateJoined: \(decodeUser.user.dateJoined)")
                print("Date: \(date)")
                await CoreDataManager.shared.createUser(
                    email: decodeUser.user.email,
                    creationData: date,
                    monthlyBudget: Int(decodeUser.user.email) ?? 0,
                    balance: Double(decodeUser.user.email) ?? 0.0
                )
                return true
            } else {
                return false
            }
        } catch {
            print("❌ Error get user: \(error)")
            throw error
        }
    }
    
    func changeDataUser(email: String, monthBudget: Int) async throws {
        guard let url = URL(string: "http://127.0.0.1:8000/api/users/me/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email, "monthly_budget": monthBudget]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, _) = try await NetworkService.shared.performRequest(request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodeUser = try decoder.decode(UserResponseWrapper.self, from: data)
            
            await CoreDataManager.shared.setEmail(decodeUser.user.email)
            await CoreDataManager.shared.setMonthlyBudget(decodeUser.user.monthlyBudget)
            
        } catch {
            throw error
        }
    }
    
    
    func logoutUser() async throws {
        guard let url = URL(string: "http://127.0.0.1:8000/api/users/logout/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            let (_, _) = try await NetworkService.shared.performRequest(request)
        } catch {
            print("❌ Error logout user: \(error)")
            throw error
        }
    }
    
    func deleteUser() async throws {
        guard let url = URL(string: "http://127.0.0.1:8000/api/users/me/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        do {
            let (_, _) = try await NetworkService.shared.performRequest(request)
        } catch {
            print("❌ Error delete user: \(error)")
            throw error
        }
    }
    
    
    // MARK: TRANSACTION
    
    func getTransactionsData() async throws {
        
        guard let startDate = await CoreDataManager.shared.getCreatinDate() else {
            print("❌ Unable to get the start date for creating transactions")
            return
        }
        
        let endDate = Date()
        let formattedStartDate = dateToString(startDate)
        let formattedEndDate = dateToString(endDate)
        
        guard let url = URL(
            string: "http://127.0.0.1:8000/api/transactions/get_transactions_data/?start_date=\(formattedStartDate)&end_date=\(formattedEndDate)"
        ) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await NetworkService.shared.performRequest(request)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodeWrapper = try decoder.decode(TransactionResponseWrapper.self, from: data)
            
            let transactionResponses = decodeWrapper.transactions
            
            for response in transactionResponses {
                guard let date = stringToDate(response.creationDate) else {
                    print("❌ Date decoding error: \(response.creationDate)")
                    continue
                }
                
                await CoreDataManager.shared.createTransaction(
                    type: response.type,
                    amount: response.amount,
                    title: response.title,
                    descriptionText: response.description,
                    category: response.category,
                    dateCreate: date,
                    paymentMethod: response.paymentMethod,
                    serverId: Int64(response.id),
                    toDoSaveContext: true
                )
            }
        } catch {
            print("Error getting transactions data: \(error)")
        }
    }
    
    func createTransaction(
        type: String,
        amount: Double,
        title: String,
        payment_method: String,
        description: String,
        category: String,
        creation_date: Date
    ) async throws {
        guard let url = URL(string: "http://127.0.0.1:8000/api/transactions/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateString = dateToString(creation_date)
        
        let body: [String: Any] = [
            "type": type,
            "amount": amount,
            "title": title,
            "payment_method": payment_method,
            "description": description,
            "category": category,
            "creation_date": dateString
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, _) = try await NetworkService.shared.performRequest(request)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let decodeTransaction = try decoder.decode(TransactionResponseGetTransaction.self, from: data)
            
            print("decodeTransaction: \(decodeTransaction.creationDate)")
            
            if let date = stringToDate(decodeTransaction.creationDate) {
                
                print("Date: \(date)")
                await CoreDataManager.shared.createTransaction(
                    type: decodeTransaction.type,
                    amount: decodeTransaction.amount,
                    title: decodeTransaction.title,
                    descriptionText: decodeTransaction.description,
                    category: decodeTransaction.category,
                    dateCreate: date,
                    paymentMethod: decodeTransaction.paymentMethod,
                    serverId: Int64(decodeTransaction.id),
                    toDoSaveContext: true
                )
                
            } else {
                print("Error: Date could not be decoded..")
            }
        } catch {
            print("Error creating transaction: \(error)")
        }
    }
    
    
    func deleteTransaction(id: Int) async throws {
        
        guard let url = URL(string: "http://127.0.0.1:8000/api/transactions/\(id)/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        do {
            let (_, _) = try await NetworkService.shared.performRequest(request)
        } catch {
            print("Error delete transaction: \(error)")
            throw error
        }
    }
    
    func updateTransaction(
        server_id: Int,
        type: String,
        amount: Double,
        title: String,
        payment_method: String,
        description: String,
        category: String,
        creation_date: Date
    ) async throws {
        guard let url = URL(string: "http://127.0.0.1:8000/api/transactions/\(server_id)/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateString = dateToString(creation_date)
        
        let body : [String: Any] = [
            "type": type,
            "amount": amount,
            "title": title,
            "payment_method": payment_method,
            "description": description,
            "category": category,
            "creation_date": dateString
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, _) = try await NetworkService.shared.performRequest(request)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let decodeTransaction = try decoder.decode(TransactionResponseGetTransaction.self, from: data)
            
            if let date = stringToDate(decodeTransaction.creationDate) {
                await CoreDataManager.shared.updateTransaction(
                    serverId: server_id,
                    newType: decodeTransaction.type,
                    newAmount: decodeTransaction.amount,
                    newTitile: decodeTransaction.title,
                    newDescription: decodeTransaction.description,
                    newCategory: decodeTransaction.category,
                    newPaymentMethod: decodeTransaction.paymentMethod,
                    newDate: date
                )
            }
        } catch {
            print("Error serializing JSON: \(error)")
            throw error
        }
    }
    
    // MARK: ANALYZE
    
    func getStatistics(startData: Date, endData: Date) async throws -> FinanceResponse {
        
        let formattedStartDate = dateToString(startData)
        let formattedEndDate = dateToString(endData)
        
        print("formattedStartDate \(formattedStartDate), formattedEndDate \(formattedEndDate)")

        guard let url = URL(string: "http://127.0.0.1:8000/api/transactions/get_analyse_data/?start_date=\(formattedStartDate)&end_date=\(formattedEndDate)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await NetworkService.shared.performRequest(request)
            
            let decoder = JSONDecoder()
            let decodeStatistics = try decoder.decode(FinanceResponse.self, from: data)
            
            return decodeStatistics
        } catch {
            print("Error serializing JSON: \(error)")
            throw error
        }
    }
    
    // MARK: GOAL
    
    func getAchievements() async throws {
        
        guard let url = URL(string: "http://127.0.0.1:8000/api/users/achievements/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await NetworkService.shared.performRequest(request)
            
            let decoder = JSONDecoder()
            let decodeAchievements = try decoder.decode(AchievementsResponseWrapper.self, from: data)
            
            for achievement in decodeAchievements.achievements.costs {
                await CoreDataManager.shared.createGoal(name: achievement.key, count: Int32(achievement.value))
            }
            
            for achievement in decodeAchievements.achievements.incomes {
                await CoreDataManager.shared.createGoal(name: achievement.key, count: Int32(achievement.value))
            }
                
            } catch {
            print("Error getting achievements: \(error)")
            throw error
        }
    }
    
    func getRecommendations(monthlyBudget: Int) async throws {
        
        guard let url = URL(string: "\(monthlyBudget)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await NetworkService.shared.performRequest(request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodeUser = try decoder.decode(UserResponseWrapper.self, from: data)
            
            await CoreDataManager.shared.setEmail(decodeUser.user.email)
            await CoreDataManager.shared.setMonthlyBudget(decodeUser.user.monthlyBudget)
            
        } catch {
            throw error
        }
    }
    
    
    private func stringToDate(_ string: String) -> Date? {
        let formatterWithoutFractions = ISO8601DateFormatter()
        formatterWithoutFractions.formatOptions = [
            .withInternetDateTime
        ]
        if let date = formatterWithoutFractions.date(from: string) {
            return date
        }
        return nil
    }
    
    private func dateToString(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime
        ]
        return formatter.string(from: date)
    }
}

enum NetworkError: Error, LocalizedError {
    case badURL
    case unauthorized
    case refreshFailed(Error?)
    case clientError(statusCode: Int, massege: String?)
    case serverError(statusCode: Int, massege: String?)
    case decodingError(Error)
    case encodingError(Error)
    case other(Error)
    
    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Bad URL"
        case .unauthorized:
            return "Unauthorized"
        case .refreshFailed(let underlyingError):
            return underlyingError?.localizedDescription ?? "Refresh failed"
        case .clientError(statusCode: let code, massege: let message):
            return "Client Error (\(code)): \(message ?? "No message")"
        case .serverError(statusCode: let code, massege: let massege):
            return "Server Error (\(code)): \(massege ?? "No message")"
        case .decodingError(let error):
            return "Decoding Error: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Encoding Error: \(error.localizedDescription)"
        case .other(let error):
            return "Other error: \(error.localizedDescription)"
        }
    }
}

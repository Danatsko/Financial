//
//  CoreDataManager.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import CoreData

@MainActor
public final class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {
        
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FinancialData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    // MARK: - CRUD Operations
    // User Operations
    func createUser(email: String, creationData: Date, monthlyBudget: Int, balance: Double) {
        let user = User(context: context)
        user.email = email
        user.balance = balance
        user.monthlyBudget = Int32(monthlyBudget)
        user.creationDate = creationData
        saveContext()
    }
    
    func fetchUser() -> User? {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.fetchLimit = 1
        do {
            guard let user = try context.fetch(fetchRequest).first else {
                print("No user found")
                return nil
            }
            return user
        } catch {
            print("Failed to fetch user: \(error)")
            return nil
        }
    }
    
    func getCreatinDate() -> Date? {
        return fetchUser()?.creationDate
    }
    
    func getMonthlyBudget() -> Int {
        return Int(fetchUser()?.monthlyBudget ?? 0)
    }
    
    func getEmail() -> String {
        return fetchUser()?.email ?? ""
    }
    
    func setMonthlyBudget(_ newBudget: Int) {
        if var user = fetchUser() {
            user.monthlyBudget = Int32(newBudget)
            saveContext()
        }
    }
    
    func setEmail(_ newEmail: String) {
        if var user = fetchUser() {
            user.email = newEmail
            saveContext()
        }
    }
    
    func deleteUser() {
        if let user = fetchUser() {
            do {
                context.delete(user)
                try context.save()
            } catch {
                print("Failed to delete user: \(error)")
            }
        }
    }
    
    func deleteAllTransactions() -> Bool {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        
        do {
            let transactions = try context.fetch(fetchRequest)
            
            for transaction in transactions {
                context.delete(transaction)
            }
            
            if let user = fetchUser() {
                user.balance = 0
            }
            
            try context.save()
            return true
        } catch {
            print("Failed to delete all transactions: \(error)")
            return false
        }
    }
    
    // Transaction Operations
    func createTransaction(
        type: String,
        amount: Double,
        title: String,
        descriptionText: String,
        category: String,
        dateCreate: Date,
        paymentMethod: String,
        serverId: Int64?,
        toDoSaveContext: Bool
    ) {
        guard let user = fetchUser() else { return }
        let transaction = Transaction(context: context)
        
        print("Transaction info \(type), \(amount), \(title) \(descriptionText), \(category), \(dateCreate), \(paymentMethod)")
        if let serverId = serverId {
            transaction.serverId = Int64(serverId)
        }
        transaction.type = type
        transaction.amount = amount
        transaction.title = title
        transaction.descriptionText = descriptionText
        transaction.category = category
        transaction.date = dateCreate
        transaction.paymentMethod = paymentMethod
        transaction.user = user
        user.transactionsSet.insert(transaction)
        user.balance += transaction.type == "incomes" ? transaction.amount : (transaction.amount * -1)
        
        if toDoSaveContext {
            saveContext()
        }
    }
    
    func fetchTransactions() -> [Transaction] {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch transactions: \(error)")
            return []
        }
    }
    
    func deleteTransaction(transaction: Transaction) {
        guard let user = fetchUser() else { return }
        do {
            context.delete(transaction)
            user.balance -= transaction.type == "incomes" ? transaction.amount : (transaction.amount * -1)
            try context.save()
        } catch {
            print("Failed to delete transaction: \(error)")
        }
    }
    
    
    func updateTransaction(
        serverId: Int,
        newType: String,
        newAmount: Double,
        newTitile: String,
        newDescription: String,
        newCategory: String,
        newPaymentMethod: String,
        newDate: Date
    ) {
        guard let user = fetchUser() else { return }
        
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "serverId == %d", serverId)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let transaction = results.first {
                user.balance -= transaction.type == "incomes" ? transaction.amount : (transaction.amount * -1)
                transaction.serverId = Int64(serverId)
                transaction.type = newType
                transaction.amount = newAmount
                transaction.title = newTitile
                transaction.descriptionText = newDescription
                transaction.category = newCategory
                transaction.paymentMethod = newPaymentMethod
                transaction.date = newDate
                
                user.balance += transaction.type == "incomes" ? transaction.amount : (transaction.amount * -1)
                
                try self.context.save()
            }
        } catch {
            print("Failed to update transaction: \(error)")
        }
    }
    
    
    // Goal Operations
    func createGoal(name: String, count: Int32) {
        guard let user = fetchUser() else { return }
        let goal = Goal(context: context)
        goal.name = name
        goal.count = count
        goal.user = user
        user.goalsSet.insert(goal)
        saveContext()
    }
    
    func fetchGoals() -> [Goal] {
        let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch goals: \(error)")
            return []
        }
    }
    
    func deleteGoal(goal: Goal) -> Bool {
        do {
            context.delete(goal)
            try context.save()
            return true
        } catch {
            print("Failed to delete goal: \(error)")
            return false
        }
    }
    
    func deleteAllGoals() {
        let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
        do {
            let goals = try context.fetch(fetchRequest)

            for goal in goals {
                context.delete(goal)
            }

            try context.save()

            print("Successfully deleted all goals.")
        } catch let error as NSError {
            print("Failed to delete all goals. \(error), \(error.userInfo)")
        }
    }
    
    func incrementGoalCount(name: String) {
        guard let user = fetchUser() else {
            return
        }
        
        let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND user == %@", name, user)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            
            guard let goalToIncrement = results.first else {
                print("Increment Goal Count Error: Goal with name '\(name)' not found.")
                return
            }
            goalToIncrement.count += 1
            try context.save()
            
        } catch {
            print("Error incrementing goal count: \(error)")
        }
    }
}

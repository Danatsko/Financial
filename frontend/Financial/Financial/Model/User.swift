//
//  User+CoreDataProperties.swift
//  FinancialApp
//
//  Created by KeeR ReeK on 08.05.2025.
//  Copyright (c) 2025 Financial

import Foundation
import CoreData


@objc(User)
public class User: NSManagedObject {

}

extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var balance: Double
    @NSManaged public var creationDate: Date?
    @NSManaged public var email: String?
    @NSManaged public var monthlyBudget: Int32
    @NSManaged public var transaction: NSSet?
    @NSManaged public var goal: NSSet?
    
    var transactionsSet: Set<Transaction> {
        get {
            return transaction as? Set<Transaction> ?? []
        }
        set {
            transaction = newValue as NSSet
        }
    }
    
    var goalsSet: Set<Goal> {
        get {
            return goal as? Set<Goal> ?? []
        }
        set {
            goal = newValue as NSSet
        }
    }
    
}




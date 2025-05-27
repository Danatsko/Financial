//
//  Transaction+CoreDataProperties.swift
//  FinancialApp
//
//  Created by KeeR ReeK on 08.05.2025.
//  Copyright (c) 2025 Financial

import Foundation
import CoreData

@objc(Transaction)
public class Transaction: NSManagedObject {
    
}

extension Transaction {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }
    
    @NSManaged public var amount: Double
    @NSManaged public var category: String?
    @NSManaged public var date: Date?
    @NSManaged public var descriptionText: String?
    @NSManaged public var id: UUID?
    @NSManaged public var paymentMethod: String?
    @NSManaged public var serverId: Int64
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var user: User?
    
}

extension Transaction: Identifiable {
    
}



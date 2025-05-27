//
//  Goal+CoreDataProperties.swift
//  FinancialApp
//
//  Created by KeeR ReeK on 08.05.2025.
//  Copyright (c) 2025 Financial

import Foundation
import CoreData

@objc(Goal)
public class Goal: NSManagedObject {

}

extension Goal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Goal> {
        return NSFetchRequest<Goal>(entityName: "Goal")
    }

    @NSManaged public var count: Int32
    @NSManaged public var name: String?
    @NSManaged public var user: User?

}

extension Goal: Identifiable {

}

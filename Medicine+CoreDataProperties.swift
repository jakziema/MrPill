//
//  Medicine+CoreDataProperties.swift
//  
//
//  Created by appcamp on 11/16/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Medicine {

    @NSManaged var amount: String?
    @NSManaged var endDate: String?
    @NSManaged var name: String?
    @NSManaged var notificationSet: NSNumber?
    @NSManaged var time: String?
    @NSManaged var taken: NSOrderedSet?

}

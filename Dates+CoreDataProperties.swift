//
//  Dates+CoreDataProperties.swift
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

extension Dates {

    @NSManaged var date: NSDate?
    @NSManaged var medicine: Medicine?

}

//
//  Medicine.swift
//  MrPill_Parsecoco
//
//  Created by appcamp on 10/31/15.
//  Copyright © 2015 appcamp. All rights reserved.
//

import Foundation
import CoreData

class Medicine: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var amount: String?
    @NSManaged var time: String?

    
}

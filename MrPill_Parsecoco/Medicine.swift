//
//  Medicine.swift
//  MrPill_Parsecoco
//
//  Created by appcamp on 10/8/15.
//  Copyright © 2015 appcamp. All rights reserved.
//

import Foundation
import Parse

class Medicine: PFObject {
    @NSManaged var medicineName: String?
    @NSManaged var amountQuantity: String?
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: Medicine.parseClassName())
        query.orderByDescending("medicineName")
        return query
    }
    
    init(medicineName: String?, amountQuantity: String?) {
        super.init()
        
        self.medicineName = medicineName
        self.amountQuantity = amountQuantity
    }
    
    override init() {
        super.init()
    }
    
}


extension Medicine: PFSubclassing {
    class func parseClassName() -> String {
        return "Medicine"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}

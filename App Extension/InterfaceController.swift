//
//  InterfaceController.swift
//  App Extension
//
//  Created by appcamp on 10/15/15.
//  Copyright © 2015 appcamp. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    //MARK: Properties
    @IBOutlet var table: WKInterfaceTable!
    var medicines = [(String, String?)]()
    
    
    //MARK: Session
    var session: WCSession!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        
    }
    
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        
        let iNeedMedicine = ["Value": "Query"]
        session.sendMessage(iNeedMedicine, replyHandler: { (content:[String : AnyObject]) -> Void in
            
            if let medicine = content["medicines"]  as? [String] {
                self.addMedicines(medicine)
                print(medicine)
                //self.reloadTable()
            }
            
            }, errorHandler: {  (error ) -> Void in
                print("We got an error from our watch device : " + error.domain)
                
            
        })
        
        
        let iNeedAmount = ["Value" : "Amount"]
        session.sendMessage(iNeedAmount, replyHandler: { (content:[String : AnyObject]) -> Void in
            
            if let quantity = content["quantity"]  as? [String] {
                self.addQuantities(quantity)
                print(quantity)
                self.reloadTable()
                
                
            }
            
            
            }, errorHandler: {  (error ) -> Void in
                print("We got an error from our watch device : " + error.domain)
                
            
        })
        
        
        
        
    }
    
    func reloadTable() {
        self.table.setNumberOfRows(medicines.count, withRowType: "tableRowController")
        var rowIndex = 0
        for item in medicines {
            if let row = self.table.rowControllerAtIndex(rowIndex) as? tableRowController {
                row.medicineLabel.setText(item.0)
                
                if let quantity = item.1 {
                    row.amountLabel.setText(quantity)
                }
                rowIndex++
            }
        }
    }
    
    func addMedicines(medicineNames: [String]) {
        for name in medicineNames {
            medicines.append((name, nil))
        }
    }
    
    func addQuantities(quantities: [String]) {
        guard medicines.count == quantities.count else { return }
        for i in 0..<medicines.count {
            medicines[i].1 = quantities[i]
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}

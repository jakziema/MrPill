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
    var medicines = [(String, String?, String?)]()
    
    @IBOutlet var alertLabel: WKInterfaceLabel!
    
    //MARK: Session
    var session: WCSession!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        
    }
    @IBAction func refresh() {
        
        refreshLabel.setHidden(true)
        table.setHidden(false)
        
        let iNeedCoreData = ["Value": "CoreData"]
        session.sendMessage(iNeedCoreData, replyHandler: { (content: [String: AnyObject]) -> Void in
            
            if let meds = content["reply"] as? [String: [String]] {
                
                if let medicineNames = meds["medicines"], amountNames = meds["amount"], timeNames = meds["time"] {
                    if medicineNames.count != 0 {
                        
                        self.addMedicines(medicineNames)
                        self.addQuantities(amountNames)
                        self.addTime(timeNames)
                        self.table.setHidden(false)
                        self.reloadTable()
                        self.alertLabel.setHidden(true)
                        
                        self.medicines.removeAll()
                        
                    } else {
                        self.alertLabel.setHidden(false)
                    }
                }
            }
            }) { (error) -> Void in
                print("We got an error from our watch device:" + error.domain)
        }
        
        
    }
    
    @IBOutlet var refreshLabel: WKInterfaceLabel!
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }

    }
    
    func reloadTable() {
        self.table.setNumberOfRows(medicines.count, withRowType: "tableRowController")
        var rowIndex = 0
        for item in medicines {
            if let row = self.table.rowControllerAtIndex(rowIndex) as? tableRowController {
                row.medicineLabel.setText(item.0)
                if let quantity = item.1, time = item.2 {
                    row.amountLabel.setText(quantity)
                    row.timeLabel.setText(time)
                    
                }
                rowIndex++
            }
        }
    }
    
    func addMedicines(medicineNames: [String]) {
        for name in medicineNames {
            medicines.append((name, nil, nil))
        }
    }
    
    func addQuantities(quantities: [String]) {
        guard medicines.count == quantities.count else { return }
        for i in 0..<medicines.count {
            medicines[i].1 = quantities[i]
        }
    }
    
    func addTime(timeNames: [String]) {
        guard medicines.count == timeNames.count else { return }
        for i in 0..<medicines.count {
            medicines[i].2 = timeNames[i]
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}

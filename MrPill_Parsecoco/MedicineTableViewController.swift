//
//  MedicineTableViewController.swift
//  MrPill_Parsecoco
//
//  Created by appcamp on 10/8/15.
//  Copyright © 2015 appcamp. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class MedicineTableViewController: PFQueryTableViewController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    @IBAction func logOutPressed(sender: AnyObject) {
        PFUser.logOut()
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        loadObjects()
    }
    
    override func queryForTable() -> PFQuery {
        let query  = Medicine.query()
        query!.cachePolicy = PFCachePolicy.CacheElseNetwork
        return query!
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject!) -> PFTableViewCell? {
        
        let cell =  tableView.dequeueReusableCellWithIdentifier("MedicineCell", forIndexPath: indexPath) as! MedicineTableViewCell
        
        let medicine = object as! Medicine
        
        if let medicineName = medicine.medicineName {
            if let amountQuantity = medicine.amountQuantity {
                cell.medicineLabel.text = "\(medicineName)"
                cell.amountLabel.text = "\(amountQuantity)"
            }
        }
        
        return cell
        
    }
}

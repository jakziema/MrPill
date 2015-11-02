//
//  MedicineTableViewController.swift
//  MrPill_Parsecoco
//
//  Created by appcamp on 10/8/15.
//  Copyright © 2015 appcamp. All rights reserved.
//

import UIKit
import Parse
import SystemConfiguration
import CoreData

class MedicineTableViewController: UITableViewController{
    
    var medicines : [Medicine] = [Medicine]()
    var fetchedResultsController: NSFetchedResultsController!
    var context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let fetchRequest = NSFetchRequest(entityName: "Medicine")
    
    @IBOutlet var tableViewMedicines: UITableView!
    
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    
    lazy var refreshCtrl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
        }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        self.tableView.addSubview(self.refreshCtrl)


        
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        
       
        fetchFromCoreData()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Actions
    @IBAction func logOutPressed(sender: AnyObject) {
        PFUser.logOut()
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        if Reachability.isConnectedToNetwork() {
            //fetching data from Parse
            
            fetchFromParse()
            fetchFromCoreData()
            tableViewMedicines.reloadData()
            
            
        } else {
            //fetching data from Core data
            fetchFromCoreData()
            logOutButton.enabled = false
            
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return medicines.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MedicineCell", forIndexPath: indexPath) as! MedicineTableViewCell
        
        // Configure the cell...
        cell.medicineLabel.text = medicines[indexPath.row].name
        cell.amountLabel.text = medicines[indexPath.row].amount
        return cell
    }
    
    // MARK: - Fetching
    func fetchFromParse() {
        
        let entity = NSEntityDescription.entityForName("Medicine", inManagedObjectContext: context)
        let query = PFQuery(className: PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    
                    if let  name = object["medicineName"] as? String,
                        amount = object["amountQuantity"] as? String {
                            
                            let predicate = NSPredicate(format: "name = %@", name)
                            self.fetchRequest.predicate = predicate
                            
                            do{
                                let fetchedEntities = try self.context.executeFetchRequest(self.fetchRequest) as! [Medicine]
                                //save to  Core Data
                                
                                
                                if fetchedEntities.count <= 0 {
                                    let medicine = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.context)
                                    medicine.setValue(name, forKey: "name")
                                    medicine.setValue(amount, forKey: "amount")
                                    
                                }
                            } catch let error as NSError{
                                print(error)
                            }
                    }
                }
                
                do {
                    try self.context.save()
                    
                } catch let error as NSError {
                    print("Could not save \(error), \(error.userInfo)")
                }
                
                
            } else {
                let ac = UIAlertController(title: "Messagge", message: "Nie przygotowano jeszcze listy leków", preferredStyle: UIAlertControllerStyle.Alert)
                ac.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)
            }
        }
    }
    
    func fetchFromCoreData() {
        
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            medicines = results  as! [Medicine]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
}

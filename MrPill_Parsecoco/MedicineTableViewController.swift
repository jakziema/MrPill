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
        
        navigationController?.navigationBar.barTintColor = UIColor(red: CGFloat(243/255.0),green: CGFloat(84/255.0),blue: CGFloat(67/255.0),alpha: CGFloat(1.0))
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        //remove extra separators
        tableView.tableFooterView = UIView(frame:CGRectZero)


        self.tableView.addSubview(self.refreshCtrl)
  
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)

    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        fetchFromCoreData()
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
            print("Jest internet")
            fetchFromParse()
            fetchFromCoreData()
            tableViewMedicines.reloadData()
            
            
            
        } else {
            print("Brak internetu")
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
        cell.timeLabel.text = medicines[indexPath.row].time
        
        // full width of the separator
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
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
                        amount = object["amountQuantity"] as? String,
                        time = object["time"] as? String
                    {
                            
                            let predicate = NSPredicate(format: "name = %@", name)
                            self.fetchRequest.predicate = predicate
                            
                            do{
                                let fetchedEntities = try self.context.executeFetchRequest(self.fetchRequest) as! [Medicine]
                                //save to  Core Data
                                
                                
                                if fetchedEntities.count <= 0 {
                                    let medicine = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.context)
                                    medicine.setValue(name, forKey: "name")
                                    medicine.setValue(amount, forKey: "amount")
                                    medicine.setValue(time, forKey: "time")
               
                                }
       
                            } catch let error as NSError{
                                print(error)
                            }
                    }
                }
            } 
        }
        
        do {
            
            try self.context.save()
            print("Context.save")

            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func fetchFromCoreData() {
        
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            medicines = results  as! [Medicine]
            print("FetchFromCoreData")
            tableViewMedicines.reloadData()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
   
    }
 
}

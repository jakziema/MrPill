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
        
        fetchFromParse()
        
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
            
            tableViewMedicines.reloadData()
            
            logOutButton.enabled = true
            
            
            
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
                        time = object["time"] as? String,
                        endDate = object["endDate"] as? String
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
                                medicine.setValue(endDate, forKey: "endDate")
                                medicine.setValue(false, forKey: "notificationSet")
                                
                            }
                            
                        } catch let error as NSError{
                            print(error)
                        }
                    }
                }
            }
            self.fetchFromCoreData()
            self.setupNotificationFromCoreData()
            
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
            let primarySortDescriptor = NSSortDescriptor(key: "time", ascending: true)
            fetchRequest.sortDescriptors = [primarySortDescriptor]
            
            fetchRequest.predicate = nil
            
            let results = try context.executeFetchRequest(fetchRequest)
            medicines = results  as! [Medicine]
            print("FetchFromCoreData")
            tableViewMedicines.reloadData()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    func setupNotificationFromCoreData() {
        let primarySortDescriptor = NSSortDescriptor(key: "time", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescriptor]
        
        do {
            let results = try context.executeFetchRequest(fetchRequest) as! [Medicine]
            
            for medicine in results {
                
                //dzisiejsza data
                let today = NSDate()
                let dateFormatter1 = NSDateFormatter()
                dateFormatter1.dateFormat = "dd-MM-yyyy"
                
                var dateFromCoreData = dateFormatter1.dateFromString(medicine.endDate!)
                
                // comparing today with end date. if today is earlier than end date setup notification
                if today.compare(dateFromCoreData!) == NSComparisonResult.OrderedAscending {
                
                if medicine.notificationSet == false {
                    
                    medicine.notificationSet = true
                    
                    print("Notification: " + medicine.name!)
                    
                    let notification = UILocalNotification()
                    notification.alertTitle = medicine.name!
                    notification.alertBody = "TAKE: " +  medicine.name! + " AMOUNT: " + medicine.amount!
                    notification.alertAction = "View list"
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    var todayDateString = dateFormatter.stringFromDate(NSDate())
                    
                    todayDateString.replaceRange(Range<String.Index>(start: todayDateString.endIndex.advancedBy(-5), end: todayDateString.endIndex), with: medicine.time!)
                    var stringDate = todayDateString
                    
                    let newDate = dateFormatter.dateFromString(todayDateString)
                    
                    //notification.fireDate = NSDate().dateByAddingTimeInterval(  60 )
                    notification.fireDate = newDate
                    print(notification.fireDate)
                    notification.soundName = UILocalNotificationDefaultSoundName
                    notification.category = "MEDICINE_CATEGORY"
                    
                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                }
                } 
                
                
                
                
                
            }
            
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func notificationSettings() {
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Sound, UIUserNotificationType.Badge]
        
        let takeAction = UIMutableUserNotificationAction()
        takeAction.identifier = "takePill"
        takeAction.title = "Biorę"
        takeAction.activationMode = UIUserNotificationActivationMode.Background
        takeAction.destructive = false
        takeAction.authenticationRequired = false
        
        let remindLaterAction = UIMutableUserNotificationAction()
        remindLaterAction.identifier = "remindLater"
        remindLaterAction.title = "Remind in 30 minutes"
        remindLaterAction.activationMode = UIUserNotificationActivationMode.Background
        remindLaterAction.destructive = false
        remindLaterAction.authenticationRequired = false
        
        //arrays of actions
        let actionsArray = NSArray(objects: takeAction, remindLaterAction)
        let actionsArrayMinimal = NSArray(objects: takeAction, remindLaterAction)
        
        //category of notification
        let medicine_category = UIMutableUserNotificationCategory()
        medicine_category.identifier = "MEDICINE_CATEGORY"
        medicine_category.setActions(actionsArray as? [UIUserNotificationAction], forContext: UIUserNotificationActionContext.Default)
        medicine_category.setActions(actionsArrayMinimal as? [UIUserNotificationAction], forContext: UIUserNotificationActionContext.Minimal)
        
        //registering notifications
        let categoriesForSettings = NSSet(objects: medicine_category)
        let newNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categoriesForSettings as? Set<UIUserNotificationCategory>)
        UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
    }
    
}

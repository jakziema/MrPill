//
//  AppDelegate.swift
//  MrPill_Parsecoco
//
//  Created by appcamp on 10/8/15.
//  Copyright © 2015 appcamp. All rights reserved.
//

import UIKit
import Parse
import WatchConnectivity
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    
    var window: UIWindow?
    var session: WCSession!
    let fetchRequest = NSFetchRequest(entityName: "Medicine")
    
    
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //UIApplication.sharedApplication().cancelAllLocalNotifications()

        Parse.setApplicationId("YWOF5qUaH9MvmTsnOXJ1BI8V3fCem4rHuSsLuGKg", clientKey: "jE5GMMR3O9iVqsYdgUyNvKxcaTVLxXogLjTjWTpm")
        
        if(WCSession.isSupported()) {
            session  = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
//        setupNotifications()
//        notificationSettings()
        

        return true
    }
    
    //MARK: NOTIFICATIONS
    
    func setupNotifications() {
        let primarySortDescriptor = NSSortDescriptor(key: "time", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescriptor]
        
        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Medicine]
            
            for medicine in results {
                
                let today = NSDate()
                let dateFormatter1 = NSDateFormatter()
                dateFormatter1.dateFormat = "dd-MM-yyyy"
                
                var dateFromCoreData = dateFormatter1.dateFromString(medicine.endDate!)
                
                // comparing today with end date. if today is earlier than end date setup notification
                if today.compare(dateFromCoreData!) == NSComparisonResult.OrderedAscending {
                    
                    let notification = UILocalNotification()
                    notification.alertTitle = "Mr Pill"
                    notification.alertBody = "TAKE: " +  medicine.name! + " AMOUNT: " + medicine.amount!
                    notification.alertAction = "View list"
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    var todayDateString = dateFormatter.stringFromDate(NSDate())
                    
                    todayDateString.replaceRange(Range<String.Index>(start: todayDateString.endIndex.advancedBy(-5), end: todayDateString.endIndex), with: medicine.time!)
                    var stringDate = todayDateString
                    
                    let newDate = dateFormatter.dateFromString(todayDateString)
                    
                    //notification.fireDate = NSDate().dateByAddingTimeInterval( 60 * 60 )
                    notification.fireDate = newDate
                    print(notification.fireDate)
                    notification.repeatInterval = NSCalendarUnit.NSDayCalendarUnit
                    notification.soundName = UILocalNotificationDefaultSoundName
                    notification.category = "MEDICINE_CATEGORY"
                    
                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
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
    

    
    //MARK: Sending Core Data
    
    var medicinesArray = [String]()
    var amountArray = [String]()
    var timeArray = [String]()
    var dict = [String: [String]]()
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        if let receivedMessage = message["Value"] {
            if receivedMessage as! String == "CoreData" {
                do {
                    let results = try managedObjectContext.executeFetchRequest(fetchRequest)
                    
                    for medicine in results {
                        medicinesArray.append(medicine.name!)
                        amountArray.append(medicine.amount!!)
                        timeArray.append(medicine.time!!)
                    }
                    
                    dict = ["medicines": medicinesArray, "amount": amountArray, "time": timeArray]
                    
                    replyHandler(["reply": dict])
                }
                
                catch let error as NSError {
                    print(error.userInfo)
                }
            }
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        if identifier == "remindLater" {
            
            print("remindLater")
            notification.fireDate = NSDate().dateByAddingTimeInterval(60)
            UIApplication.sharedApplication().scheduleLocalNotification(notification)

        } else if identifier == "takePill" {
            
            print("Pill taken")
            
            
        }
        
        completionHandler()
    }

    func applicationWillResignActive(application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        

    }
    
    func applicationWillTerminate(application: UIApplication) {
        self.saveContext()

    }
    
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "appcamp.Example_of_Core_Data" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
}


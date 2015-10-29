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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    
    var window: UIWindow?
    var session: WCSession!
    
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Parse.setApplicationId("YWOF5qUaH9MvmTsnOXJ1BI8V3fCem4rHuSsLuGKg", clientKey: "jE5GMMR3O9iVqsYdgUyNvKxcaTVLxXogLjTjWTpm")
        
        if(WCSession.isSupported()) {
            session  = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        return true
    }
    
    
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        // handle message
        var medicines = [String]()
        var quantity = [String]()
        
        if let receivedMessage = message["Value"] {
            if receivedMessage as! String == "Query" {
                let query = PFQuery(className: "Medicine")
                query.cachePolicy = PFCachePolicy.NetworkElseCache

                query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if error == nil {
                        for medicine in objects! {
                            if let zawartosc = medicine["medicineName"] as? String {
                                medicines.append(zawartosc)
                            }
                        }
                    }
                    // sending dict
                    replyHandler(["medicines": medicines])
                })
                
                
                
            } else if receivedMessage as! String == "Amount" {
                let query = PFQuery(className: "Medicine")
                query.cachePolicy = PFCachePolicy.NetworkElseCache

                query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if error == nil {
                        for quantity1 in objects! {
                            if let zawartosc = quantity1["amountQuantity"] as? String {
                                quantity.append(zawartosc)
                            }
                        }
                    }
                    // sending dict
                    replyHandler(["quantity": quantity])
                })
            }
        }
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
        
    }
    
    
}


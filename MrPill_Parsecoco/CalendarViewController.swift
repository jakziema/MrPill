//
//  CalendarViewController.swift
//  MrPill_Parsecoco
//
//  Created by appcamp on 11/14/15.
//  Copyright © 2015 appcamp. All rights reserved.
//

import Foundation
import CKCalendar
import CoreData


class CalendarViewController: UIViewController, CKCalendarDelegate {
    
    var context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let fetchRequest = NSFetchRequest(entityName: "Medicine")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let calendar = CKCalendarView()
        
        calendar.frame.origin.x = 25
        calendar.frame.origin.y = 150
        
        self.view.addSubview(calendar)
        
        
        calendar.delegate = self
        
        
    }
    
    
    
    
    
    var dates = [NSDate(timeIntervalSinceNow: 60*60*24*2), NSDate(timeIntervalSinceNow: 60*60*24*3), NSDate(timeIntervalSinceNow: 60*60*24*5), NSDate(timeIntervalSinceNow: 60*60*24*7)]
    
    func calendar(calendar: CKCalendarView!, configureDateItem dateItem: CKDateItem!, forDate date: NSDate!) {
        
        
        for dateTaken in dates {
            if calendar.date(date, isSameDayAsDate: dateTaken) {
                dateItem.backgroundColor = UIColor.redColor()
            }
        }
        
    }
    
    func calendar(calendar: CKCalendarView!, didSelectDate date: NSDate!) {
        
    }
}

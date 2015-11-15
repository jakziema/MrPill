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
    let fetchRequestDate = NSFetchRequest(entityName: "Dates")
    let fetchRequestMedicine = NSFetchRequest(entityName: "Medicine")
    
    
    var medicine : Medicine?
    
    var dates = [NSDate]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            
            navigationController?.title = medicine!.name!
            
            let resultsMedicines  = try context.executeFetchRequest(fetchRequestMedicine)
            let resultsDates = try context.executeFetchRequest(fetchRequestDate)
            fetchRequestMedicine.predicate = NSPredicate(format: "name == %@ ", medicine!.name!)
            
            
            for date in resultsDates {
                dates.append(date.date as! NSDate!)
            }
            
            
        } catch let error as NSError {
            print(error.userInfo)
        }
        
        //MARK: - Calendar
        let calendar = CKCalendarView()
        calendar.frame.origin.x = 25
        calendar.frame.origin.y = 150
        self.view.addSubview(calendar)
        calendar.delegate = self
        
        
    }
    
    
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

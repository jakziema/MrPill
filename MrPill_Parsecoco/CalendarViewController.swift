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
    @IBOutlet var medicineLabel: UILabel!
    
    
    var medicine : Medicine?
    
    var dates = [NSDate]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            
            navigationController?.title = medicine!.name!

            for elem in (medicine?.taken)! {
                print("tessst: \(elem.date!)")
                
                dates.append(elem.date!!)
            }
            
            medicineLabel.text = medicine!.name!
   
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

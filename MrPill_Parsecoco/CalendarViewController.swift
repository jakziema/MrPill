//
//  CalendarViewController.swift
//  MrPill_Parsecoco
//
//  Created by appcamp on 11/14/15.
//  Copyright © 2015 appcamp. All rights reserved.
//

import Foundation
import CKCalendar


class CalendarViewController: UIViewController, CKCalendarDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let calendar = CKCalendarView()
        
        calendar.frame.origin.x = 10
        calendar.frame.origin.y = 100
        
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

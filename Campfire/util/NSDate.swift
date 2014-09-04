//
//  NSDate.swift
//  Campfire
//
//  Created by GoldRatio on 9/4/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

extension NSDate {
    func timeAgo() -> String {
        let now = NSDate.date()
        let calendar = NSCalendar.currentCalendar()
        let startDay = calendar.ordinalityOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit: NSCalendarUnit.EraCalendarUnit, forDate: self)
        let endDay = calendar.ordinalityOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit: NSCalendarUnit.EraCalendarUnit, forDate: now)
    
        var format:String? = nil
    
        let diffDays = endDay - startDay
        if (diffDays == 0) {
            let hourComponent = calendar.component(NSCalendarUnit.HourCalendarUnit, fromDate: self)
            if (hourComponent < 12) {
                format = "上午HH:mm"
            }
            else if (hourComponent >= 12 ) {
                format = "下午 HH:mm"
            }
        }
        else if (diffDays == 1) {
            format = "昨天"
        }
        else {
            format = "YY-M-d"
        }
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.stringFromDate(self)
    }
}
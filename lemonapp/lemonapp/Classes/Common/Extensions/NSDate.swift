//
//  NSDate.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation
import SwiftDate
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
/*
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}
 */



extension Date {
    
    // "MM/dd/yy"
    func shortDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yy"
        return dateFormatter.string(from: self)
    }
    
    func stringWithFormat(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func smartDateString() -> String {
        let timeZone = TimeZone.current
        let calendar = Calendar.current
        let region = Region(tz: timeZone, cal: calendar, loc: Locale.current)
        
        let dateInRegion = self.inRegion(region: region)
        
        if dateInRegion.isToday {
            return dateInRegion.string(format:DateFormat.custom("h:mm a")) ?? ""
        } else if dateInRegion.isYesterday {
            return "Yesterday"
        } else {
            let nowInRegion = Date().inRegion(region: region)
            let minDateToShowWeekday = nowInRegion - 7.days
            if minDateToShowWeekday < dateInRegion {
                //2-6 days before now
                return dateInRegion.string(format:DateFormat.custom("EEEE")) ?? ""
            }
            return self.shortDateString()
        }
    }
    
    func isSameDateAsToday() -> Bool {
        let calendar = Calendar.current
        let day: NSCalendar.Unit = .day
        let components = (calendar as NSCalendar).components(day, from: self)
        let todayComponents = (calendar as NSCalendar).components(day, from: Date())
        return components.day == todayComponents.day
    }
    
    func weekday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
    
    func time() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ha"
        return dateFormatter.string(from: self)
    }
    
    func timeHM() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm"
        return dateFormatter.string(from: self)
    }
    
    func amPm() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a"
        return dateFormatter.string(from: self)
    }

    // value in range 0..6
    func weekdayNumber() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEEE"
        let weekday = dateFormatter.string(from: self)
        return dateFormatter.weekdaySymbols!.index(of: weekday)!
    }
    
    func shortWeekday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: self)
    }
    
    func tomorrow() -> Date? {
        let calendar = Calendar.current
        var oneDay = DateComponents()
        oneDay.day = 1
        return (calendar as NSCalendar).date(byAdding: oneDay, to: self, options: [])
    }
    
    func serverString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: self)
    }
    
    func makeMondayIfSunday() -> Date {
        let timeZone = TimeZone.current
        let calendar = Calendar.current
        let region = Region( tz: timeZone, cal: calendar, loc: Locale.current)
        
        let nowInRegion = self.inRegion(region: region)
        if (nowInRegion.weekday == 1) { // Sunday
            return self.tomorrow()!
        }
        return self
    }
    
    func pickupShift(_ pickupETA: Int) -> Date {
        var pickupInRegion = self.addingTimeInterval(Double(pickupETA * 60))
        var beforeWorkingTime = false
        var afterWorkingTime = false
        
        switch pickupInRegion.weekdayNumber() {
        case 0: //Sunday
            beforeWorkingTime = pickupInRegion < pickupInRegion.dateAt(12, minutes: 0)
            afterWorkingTime = pickupInRegion > pickupInRegion.dateAt(19, minutes: 0)
            break
        case 5: //Friday
            beforeWorkingTime = pickupInRegion < pickupInRegion.dateAt(8, minutes: 0)
            afterWorkingTime = pickupInRegion > pickupInRegion.dateAt(19, minutes: 0)
            break
        case 6: //Saturday
            beforeWorkingTime = pickupInRegion < pickupInRegion.dateAt(10, minutes: 0)
            afterWorkingTime = pickupInRegion > pickupInRegion.dateAt(18, minutes: 0)
            break
        default: //Weekdays
            beforeWorkingTime = pickupInRegion < pickupInRegion.dateAt(8, minutes: 0)
            afterWorkingTime = pickupInRegion > pickupInRegion.dateAt(22, minutes: 0)
            break
        }
        
//        Monday: 8am - 10pm
//        Tuesday: 8am - 10pm
//        Wednesday: 8am - 10pm
//        Thursday: 8am - 10pm
//        
//        Friday: 8am - 7pm
//        Saturday: 10am - 6pm
//        Sunday: 12pm - 7pm
    
        if beforeWorkingTime || afterWorkingTime {
            pickupInRegion = afterWorkingTime ? pickupInRegion.tomorrow()! : pickupInRegion
            switch pickupInRegion.weekdayNumber() {
            case 0: //Sunday
                return pickupInRegion.dateAt(12, minutes: 0).addingTimeInterval(Double(pickupETA * 60))
            case 5: //Friday
                return  pickupInRegion.dateAt(8, minutes: 0).addingTimeInterval(Double(pickupETA * 60))
            case 6: //Saturday
                return pickupInRegion.dateAt(10, minutes: 0).addingTimeInterval(Double(pickupETA * 60))
            default: //Weekdays
                return pickupInRegion.dateAt(8, minutes: 0).addingTimeInterval(Double(pickupETA * 60))
            }
        } else {
            return pickupInRegion
        }
    }
}

extension Date {
    
    static func fromServerString(_ string: String?) -> Date? {
        var string = string
        if let range  = string?.range(of: ".") {
            string = string?.substring(to: range.lowerBound)
        }
        if let string = string {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            return dateFormatter.date(from: string)
        }
        return nil
    }
}

extension Date {
    
    func dateAt(_ hours: Int, minutes: Int) -> Date{
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var date_components = (calendar as NSCalendar).components([.year, .month, .day], from: self)
        
        date_components.hour = hours
        date_components.minute = minutes
        date_components.second = 0
        
        let newDate = calendar.date(from: date_components)!
        return newDate
    }
}

extension Date {

    func yearsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }

    func monthsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }

    func weeksFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }

    func daysFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }

    func hoursFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }

    func minutesFrom(_ date: Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }

    func secondsFrom(_ date: Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
}
/*
public func ==(lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 == rhs.timeIntervalSince1970
}

public func <(lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 < rhs.timeIntervalSince1970
}
public func >(lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 > rhs.timeIntervalSince1970
}
public func <=(lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 <= rhs.timeIntervalSince1970
}
public func >=(lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 >= rhs.timeIntervalSince1970
}
 */

//
//  DeliveryPricing.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftDate

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


final class DeliveryPricing {
    
    var type: DeliveryOption
    var amount: Double
    var active: Bool = true
    
    var isAvailable: Bool {
        let timeZone = TimeZone.current
        let region = Region(tz: timeZone, cal: Calendar.current, loc: Locale.current)
        
        let date = Date()
        let nowInRegion: DateInRegion! = date.inRegion(region: region)
        
        if nowInRegion.isFriday {
            if nowInRegion.hour < 16 {
                return type == .tomorrow || type == .afterTomorrow
            } else {
                return type == .afterTomorrow
            }
        }
        
        if nowInRegion.isSaturday {
            return type == .afterTomorrow
        }
        
        if nowInRegion.isSunday {
            if nowInRegion.hour < 16 {
                return type == .tomorrow || type == .afterTomorrow
            } else {
                return type == .afterTomorrow
            }
        }
        
        if (type == .today && nowInRegion.hour > 9 && nowInRegion.hour < 16 ) {
            return false
        }
        return true
    }
    
    init(type: DeliveryOption, amount: Double) {
        self.type = type
        self.amount = amount
    }
    
    func titleForDate(_ date: Date) -> String {
        let deliveryDate = self.deliveryDateForDate(date)
        
        let isToday = deliveryDate.isSameDateAsToday()
        let todayOptionTitle = isToday ? NSLocalizedString("Today", comment: "") : deliveryDate.shortWeekday()
        
        switch self.type {
        case .today:
            return "\(todayOptionTitle)\n+\(amount.asCurrencyWithoutSymbol())"
        case .tomorrow:
            return "\(deliveryDate.shortWeekday())\n+\(amount.asCurrencyWithoutSymbol())"
        case .afterTomorrow:
            return "\(deliveryDate.shortWeekday())\nFREE"
        }
    }
    
    
    func weekdayTitleForDate(_ date: Date) -> String {
        let deliveryDate = self.deliveryDateForDate(date)
        
        let isToday = deliveryDate.isSameDateAsToday()
        let todayOptionTitle = isToday ? NSLocalizedString("Today", comment: "") : deliveryDate.shortWeekday()
        
        switch self.type {
        case .today:
            return todayOptionTitle
        case .tomorrow:
            return deliveryDate.shortWeekday()
        case .afterTomorrow:
            return deliveryDate.shortWeekday()
        }
    }
    
    func priceForDate(_ date: Date) -> String {
        switch self.type {
        case .today:
            return "+\(amount.asCurrencyWithoutSymbol())"
        case .tomorrow:
            return "+\(amount.asCurrencyWithoutSymbol())"
        case .afterTomorrow:
            return "FREE"
        }
    }

    
    func deliveryDateForDate(_ orderDate: Date) -> Date {
        let timeZone = TimeZone.current
        let region = Region(tz: timeZone, cal: Calendar.current,  loc: Locale.current)
        
        let nowInRegion: DateInRegion! = orderDate.inRegion(region: region)
        
        if nowInRegion.isFriday {
            return deliveryDateForFridayDate(orderDate, dateInRegion: nowInRegion)
        }
        if nowInRegion.isSaturday {
            return deliveryDateForSaturdayDate(orderDate, dateInRegion: nowInRegion)
        }
        if nowInRegion.isSunday {
            return deliveryDateForSundayDate(orderDate, dateInRegion: nowInRegion)
        }

        switch self.type {
        case .today:
            if nowInRegion.hour < 9 {
                return orderDate
            }
            return orderDate.tomorrow()!.makeMondayIfSunday()
        case .tomorrow:
            if nowInRegion.hour < 16 {
                return orderDate.tomorrow()!.makeMondayIfSunday()
            }
            return orderDate.tomorrow()!.tomorrow()!.makeMondayIfSunday()
        case .afterTomorrow:
            if nowInRegion.hour < 16 {
                return orderDate.tomorrow()!.tomorrow()!.makeMondayIfSunday()
            }
            return orderDate.tomorrow()!.tomorrow()!.tomorrow()!.makeMondayIfSunday()
        }
    }
    
    
    func deliveryDateForFridayDate(_ date: Date, dateInRegion: DateInRegion) -> Date {
        switch self.type {
        case .today:
            // Not Available
            // return anything
            return date
        case .tomorrow:
            if dateInRegion.hour < 16 {
                // deliver tomorrow = on Saturday
                return date.tomorrow()!
            }
            
            // Not Available
            // return anything
            return date
        case .afterTomorrow:
            // deliver on Monday
            return date.tomorrow()!.tomorrow()!.makeMondayIfSunday()
        }
    }
    
    
    func deliveryDateForSaturdayDate(_ date: Date, dateInRegion: DateInRegion) -> Date {
        switch self.type {
        case .today:
            // Not Available
            // return anything
            return date
        case .tomorrow:
            // Not Available
            // return anything
            return date
        case .afterTomorrow:
            // deliver on Monday
            return date.tomorrow()!.tomorrow()!
        }
    }
    
    
    func deliveryDateForSundayDate(_ date: Date, dateInRegion: DateInRegion) -> Date {
        switch self.type {
        case .today:
            // Not Available
            // return anything
            return date
        case .tomorrow:
            if dateInRegion.hour < 16 {
                // deliver on Monday
                date.tomorrow()!
            }
            // Not Available
            // return anything
            return date
        case .afterTomorrow:
            // deliver on Tuesday
            return date.tomorrow()!.tomorrow()!
        }
    }
    
    
    class func defaultPricing() -> [DeliveryPricing] {
        let today = DeliveryPricing(type: .today, amount: 14.99)
        let tomorrow = DeliveryPricing(type: .tomorrow, amount: 4.99)
        let free = DeliveryPricing(type: .afterTomorrow, amount: 0)
        return [today, tomorrow, free]
    }
}

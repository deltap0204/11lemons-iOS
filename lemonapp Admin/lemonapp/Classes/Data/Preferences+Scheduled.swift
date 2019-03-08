//
//  Preferences+Scheduled.swift
//  lemonapp
//
//  Created by Svetlana Dedunovich on 5/4/16.
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftDate

extension Preferences {

    static func nextPickupDateString(_ frequency: Int, weekday: Int?, currentDate: Date) -> String {
        guard let weekday = weekday else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        formatter.locale = Locale(identifier: "en_US")
        let currentWeekday = currentDate.weekdayNumber()
        if currentWeekday < weekday {
            let diff = weekday - currentWeekday
            let date = currentDate + diff.days
            return formatter.string(from: date)
        } else if currentWeekday == weekday {
            let date = currentDate + 7.days
            return formatter.string(from: date)
        } else { // currentWeekday > weekday
            let diff = 7 - (currentWeekday - weekday)
            let date = currentDate + diff.days
            return formatter.string(from: date)
        }
    }
}

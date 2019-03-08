//
//  DateInRegion.swift
//  lemonapp
//
//  Created by Svetlana Dedunovich on 4/28/16.
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftDate


extension DateInRegion {
    
    var isFriday: Bool {
        if (self.weekday == 6) { // Friday
            return true
        }
        return false
    }
    
    var isSaturday: Bool {
        if (self.weekday == 7) { // Saturday
            return true
        }
        return false
    }
    
    var isSunday: Bool {
        if (self.weekday == 1) { // Sunday
            return true
        }
        return false
    }
}
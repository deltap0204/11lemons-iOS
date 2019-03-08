//
//  DeliveryProposalText.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
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



func deliveryTimeConstraintForDate(_ date: Date) -> String {
    let timeZone = TimeZone.current
    let region = Region(tz: timeZone, cal: Calendar.current,  loc: Locale.current)
    
    let now = Date()
    let nowInRegion = now.inRegion(region: region)
    
    // Special cases:
    if nowInRegion.isFriday {
        if nowInRegion.hour < 16 {
            let h = 15 - nowInRegion.hour
            let m = 59 - nowInRegion.minute
            return "\(h)h \(m)m"
        }
        let h = 23 - nowInRegion.hour
        let m = 59 - nowInRegion.minute
        return "\(h)h \(m)m"
    } else if nowInRegion.isSaturday {
        let h = 23 - nowInRegion.hour
        let m = 59 - nowInRegion.minute
        return "\(h)h \(m)m"
    } else if nowInRegion.isSunday {
        if nowInRegion.hour < 16 {
            let h = 15 - nowInRegion.hour
            let m = 59 - nowInRegion.minute
            return "\(h)h \(m)m"
        }
        let h = 23 - nowInRegion.hour
        let m = 59 - nowInRegion.minute
        return "\(h)h \(m)m"
    }
    
    // Common logic:
    if nowInRegion.hour < 9 {
        let h = 9 - nowInRegion.hour
        let m = 59 - nowInRegion.minute
        return "\(h)h \(m)m"
    } else if nowInRegion.hour < 16 {
        let h = 15 - nowInRegion.hour
        let m = 59 - nowInRegion.minute
        return "\(h)h \(m)m"
    }
    
    let h = 23 - nowInRegion.hour
    let m = 59 - nowInRegion.minute
    return "\(h)h \(m)m"
}


func deliveryTextForTimeConstraint(_ constraint: String) -> NSAttributedString {
    let text = "\(NSLocalizedString("Order within", comment: "")) \(constraint) \(NSLocalizedString("to get delivery by", comment: "")):"
    let constraintRange = (text as NSString).range(of: constraint)
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = NSTextAlignment.center
    
    let attributedText = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17), NSAttributedStringKey.foregroundColor : UIColor.white, NSAttributedStringKey.paragraphStyle: paragraphStyle])
    attributedText.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.appBlueColor, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17)], range: constraintRange)
    return attributedText
}

//
//  NotificationsSettings.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


enum NotificationsSettings: String {
    case InApp, Email, Text
    
    func title() -> String {
        switch self {
        case .InApp:
            return NSLocalizedString("In-App", comment: "")
        case .Email:
            return NSLocalizedString("email", comment: "")
        case .Text:
            return NSLocalizedString("Text Message", comment: "")
        }
    }
}
//
//  MenuItem.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond

enum MenuItem: String {
    
    case Profile, UserDashboard, CloudCloset, Preferences, Settings, Pricing, Support
    
    var iconAssetId: UIImage.AssetIdentifier {
        switch self {
        case .Profile:
            return .ProfileIcon
        case .UserDashboard:
            return .Dashboard
        case .CloudCloset:
            return .CloudCloset
        case .Preferences:
            return .PreferencesIcon
        case .Settings:
            return .SettingsIcon
        case .Pricing:
            return .PricingIcon
        case .Support:
            return .SupportIcon
        }
    }
    
    var title: String {
        switch self {
        case .UserDashboard:
            return "Dashboard"
        default:
            return self.rawValue
        }
    }
}

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
    
    case Profile, UserDashboard, AdminDashboard, CloudCloset, Preferences, Settings, Pricing, Support, Contacts, Messages, Products, Analytics
    
    var iconAssetId: UIImage.AssetIdentifier {
        switch self {
        case .Profile:
            return .ProfileIcon
        case .UserDashboard, .AdminDashboard:
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
        case .Contacts:
            return .ProfileIcon
        case .Messages:
            return .MessagesIcon
        case .Products:
            return .PricingIcon
        case .Analytics:
            return .AnalyticsIcon
        }
    }
    
    var title: String {
        switch self {
        case .AdminDashboard, .UserDashboard:
            return "Dashboard"
        case .Products:
            return "Pricing"
        default:
            return self.rawValue
        }
    }
}
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
    
    case Profile, AdminDashboard, CloudCloset, Settings, Contacts, Messages, Products, Analytics
    
    var iconAssetId: UIImage.AssetIdentifier {
        switch self {
        case .Profile:
            return .ProfileIcon
        case .AdminDashboard:
            return .Dashboard
        case .CloudCloset:
            return .CloudCloset
        case .Settings:
            return .SettingsIcon
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
        case .AdminDashboard:
            return "Dashboard"
        case .Products:
            return "Pricing"
        default:
            return self.rawValue
        }
    }
}

//
//  UIImage.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit


extension UIImage {
    
    enum AssetIdentifier: String {
        case TopLeftLemonBg, DarkLemonBg, BlurredLemonBg
        case ProfileIcon, OrdersIcon, SettingsIcon, PricingIcon, SupportIcon, CloudCloset, Dashboard, MessagesIcon, AnalyticsIcon
        case PreferencesWhite, SettingsWhite, DarkBackArrow, WhiteBackArrow
        case ApplePayButton, ApplePayIconWhite, ApplePayIconWhiteWithoutBorder
        case NotesCameraNormal, NotesCameraRed
        case Knob, MaxBg, MinBg, KnobWhite
        case SuccessIcon, AlertIcon
        case ValidationSuccess, ValidationError, PlusCircle, BottomArrow
    }
    
    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
    
}

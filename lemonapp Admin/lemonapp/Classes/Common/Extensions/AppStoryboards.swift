//
//  AppStoryboards.swift
//  lemonapp
//
//  Created by mac-190-mini on 12/23/15.
//  Copyright © 2015 11lemons. All rights reserved.
//

import UIKit


enum AppStoryboard: String {
    
    case Splash
    case Auth
    case AdminOrders
    case NewOrder
    case Settings
    case Profile
    case CommonContainer
    case CloudCloset
    case OrderServicesAndReceipt
    case Product
}

extension UIStoryboard {
    
    convenience init(storyboard: AppStoryboard, bundle storyboardBundleOrNil: Bundle? = nil) {
        self.init(name: storyboard.rawValue, bundle: storyboardBundleOrNil)
    }
    
}

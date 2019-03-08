//
//  ServiceType.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


enum ServiceType: String {
    case WashFold, LaunderPress, DryClean
    
    func title() -> String {
        switch self {
        case .WashFold:
            return NSLocalizedString("Wash & Fold", comment: "")
        case .LaunderPress:
            return NSLocalizedString("Launder & Press", comment: "")
        case .DryClean:
            return NSLocalizedString("Dry Cleaning", comment: "")
        }
    }
}
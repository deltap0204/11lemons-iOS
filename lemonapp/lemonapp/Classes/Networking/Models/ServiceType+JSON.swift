//
//  ServiceType+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON


extension ServiceType {
    
    func encode() -> String {
        switch self {
        case .WashFold:
            return "WashFold"
        case .DryClean:
            return "DryClean"
        case .LaunderPress:
            return "LaunderPress"
        }
    }
    
}
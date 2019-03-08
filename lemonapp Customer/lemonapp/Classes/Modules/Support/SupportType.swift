//
//  SupportType.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


enum SupportType {
 
    case call
    case text
    case email
    case faq
    case termsOrUse
    case privacyPolicy
    
    var isAction: Bool {
        get {
            switch self {
            case .call, .text, .email:
                return true
            default:
                return false
            }
        }
    }
}

//
//  OrderPaymentStatus.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 1/30/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

enum OrderPaymentStatus : Int {
    
//    case paymentNotProcessed = 1
//    case applePayPending = 2
//    case applePayComplete = 3
//    case ccDecline = 5
//    case ccPending = 6
//    case paymentProcessedSuccessfully = 7
    case paymentNotProcessed = 1
    case withError = 8
    case decline = 5
    case paymentProcessedSuccessfully = 7
    
    static let allValues = [paymentNotProcessed, decline, withError, paymentProcessedSuccessfully]
    
    var color: UIColor {
        switch self {
        case .paymentNotProcessed:
            return UIColor.paymentNotProcessedColor
        case .paymentProcessedSuccessfully:
            return UIColor.paymentProcessedColor
        case .decline:
            return UIColor.paymentDeclinedColor
        case .withError:
            return UIColor.paymentDeclinedColor
        
        }
    }
    
    var icon: UIImage {
        switch self {
        case .paymentNotProcessed:
            return UIImage(named: "TagSyncIcon")!
        case .paymentProcessedSuccessfully:
            return UIImage(named: "paymentSuccess")!
        case .decline:
            return UIImage(named: "paymentError")!
        case .withError:
            return UIImage(named: "paymentError")!
        }
    }
}

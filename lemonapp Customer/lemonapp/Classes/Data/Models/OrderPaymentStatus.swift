//
//  OrderPaymentStatus.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 1/30/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

enum OrderPaymentStatus : Int {
    
    case paymentNotProcessed = 1
    case applePayPending = 2
    case applePayComplete = 3
    case ccDecline = 5
    case ccPending = 6
    case paymentProcessedSuccessfully = 7

    static let allValues = [paymentNotProcessed, applePayPending, applePayComplete, ccDecline, ccPending, paymentProcessedSuccessfully]
    
    var color: UIColor {
        switch self {
        case .paymentNotProcessed:
            return UIColor.paymentNotProcessedColor
        case .applePayPending:
            return UIColor.paymentNotProcessedColor
        case .applePayComplete:
            return UIColor.paymentProcessedColor
        case .ccDecline:
            return UIColor.paymentDeclinedColor
        case .ccPending:
            return UIColor.paymentNotProcessedColor
        case .paymentProcessedSuccessfully:
            return UIColor.paymentProcessedColor
        }
    }
    
    var icon: UIImage {
        switch self {
        case .paymentNotProcessed:
            return UIImage(named: "TagSyncIcon")!
        case .paymentProcessedSuccessfully:
            return UIImage(named: "paymentSuccess")!
        case .applePayPending:
            return UIImage(named: "TagSyncIcon")!
        case .applePayComplete:
            return UIImage(named: "paymentSuccess")!
        case .ccDecline:
            return UIImage(named: "paymentError")!
        case .ccPending:
            return UIImage(named: "paymentError")!
        }
    }
}

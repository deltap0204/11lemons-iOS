//
//  Order+Helper.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 1/30/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

final class OrderHelper {
    
    static func getStatusColor(_ order: Order) -> UIColor {
        let orderStatus = order.status
        switch orderStatus {
        case .awaitingPickup:
            return UIColor.appBlueColor
        case .pickedUp:
            return UIColor.appBlueColor
        case .atFacility:
            return UIColor.appBlueColor
        case .outForDelivery:
            return UIColor.appBlueColor
        case .delivered:
            return UIColor.appBlueColor
        case .archived:
            return UIColor.appBlueColor
        case .hold:
            return UIColor.appBlueColor
        case .canceled:
            return UIColor.appBlueColor
        case .scheduled:
            return UIColor.appBlueColor
        }
    }
    
    static func getPaymentStatusColor(_ order: Order) -> UIColor {
        return order.paymentStatus.color
    }
    
    static func getTotalAmount(_ order: Order) -> Double {
        var total = 0.0
        order.orderDetails?.forEach { orderDetail in
            total = total + (orderDetail.total ?? 0)
        }
        return total
    }
    
    static func getPaymentStatusIcon(_ order: Order) -> UIImage? {
        if order.paymentStatus == OrderPaymentStatus.paymentProcessedSuccessfully {
            return UIImage(named:"paymentSuccess")
        } else if order.orderDetails != nil && order.orderDetails!.count > 0 {
            if order.paymentStatus == OrderPaymentStatus.paymentNotProcessed {
                return UIImage(named:"TagSyncIcon")
            } else if order.paymentStatus == OrderPaymentStatus.decline {
                return UIImage(named:"paymentError")
            }
            else if order.paymentStatus == OrderPaymentStatus.withError {
                return UIImage(named:"paymentError")
            }
        }
        return order.paymentStatus.icon
    }
    
    static func getReceiptPaymentStatus(_ order: Order) -> UIImage {
        switch order.paymentStatus {
        case .paymentNotProcessed:
            return UIImage(named: "ic_bottom_arrow")!
        case .paymentProcessedSuccessfully:
            return UIImage(named: "paymentSuccess")!
        case .decline:
            return UIImage(named: "paymentError")!
        case .withError:
            return UIImage(named: "paymentError")!
        default:
            return UIImage(named: "ic_bottom_arrow")!
        }
    }
}

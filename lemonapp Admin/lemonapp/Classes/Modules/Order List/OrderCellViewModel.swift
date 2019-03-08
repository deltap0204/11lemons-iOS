//
//  OrderCellViewModel.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation
import MessageUI
import Bond

final class OrderCellViewModel: ViewModel {
    
    let orderId: String
    let deliveryStatus: String
    let orderStatus: OrderStatus
    let shouldWarnUser: Bool
    let shouldMessageButtons: Bool
    let shouldPhoneButtons: Bool
    let shouldAccessoryArrow: Bool
    let statusImage: UIImage?
    let statusCahngedDate: String?
    var statusColor: UIColor
    let canArchive: Bool
    let viewed: Observable<Bool>
    let updated: Observable<Bool>
    var lastModified: Date?
    
    let order: Order
    
    let canCancel: Bool
    
    init(order: Order) {
        self.order = order
        self.viewed = order.viewed
        orderId = "\(NSLocalizedString("Order", comment: "")) #\(order.id)"
        
        switch order.status {
        case .awaitingPickup:
            deliveryStatus = order.status.comments(order.delivery.estimatedPickupDate)
        default:
            deliveryStatus = order.status.comments(order.delivery.estimatedArrivalDate)
        }
        
        orderStatus = order.status
        shouldWarnUser = order.status.isExceptional
        shouldMessageButtons = order.status == .hold && MFMessageComposeViewController.canSendText()
        shouldPhoneButtons = order.status == .hold && UIApplication.shared.canOpenURL(URL(string: "tel://")!)
        statusImage = order.status.image
        if let modified = order.lastModified {
            statusCahngedDate = modified.smartDateString()
        } else {
            statusCahngedDate = ""
        }
        statusColor = order.status == .hold ? UIColor.appRedColor() : viewed.value ? UIColor.white : UIColor.appBlueColor
        shouldAccessoryArrow = (order.orderDetails != nil && !order.orderDetails!.isEmpty && order.status != .pickedUp) || order.status == .awaitingPickup
        canArchive = order.status == .canceled || order.status == .delivered
        canCancel = order.status == OrderStatus.awaitingPickup
        
        updated = order.updated

        viewed.observeNext { [weak self] in
            if let strongSelf = self {
                strongSelf.statusColor = strongSelf.order.status == .hold ? UIColor.appRedColor() : $0 ? UIColor.white : UIColor.appBlueColor
            }
        }
        lastModified = order.lastModified
    }
}

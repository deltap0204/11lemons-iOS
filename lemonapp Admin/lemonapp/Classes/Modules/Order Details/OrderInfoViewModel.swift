//
//  OrderInfoViewModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


final class OrderInfoViewModel: OrderDetailViewModel {
    
    init(order: Order) {
        super.init()
        type = .info
        infoTitle = "Order Date\nOrder #\nOrder Total"
        
        let dateString = order.orderPlaced?.stringWithFormat("MMM dd, yyyy") ?? ""
        let amountString = order.orderAmount.amount.asCurrency()
        let count = order.orderDetails?.reduce(0) { count, detail in
            return (count ?? 0) + (detail.quantity ?? 0)
        }
        let itemsCount = "\(count ?? 0) \(NSLocalizedString("items", comment: ""))"
        info = "\(dateString)\n\(order.id)\n\(amountString) (\(itemsCount))"
    }
}

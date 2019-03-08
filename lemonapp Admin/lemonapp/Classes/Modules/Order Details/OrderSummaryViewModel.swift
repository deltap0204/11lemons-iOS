//
//  OrderSummaryViewModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


final class OrderSummaryViewModel: OrderDetailViewModel {

    var total = ""
    
    init(order: Order) {
        super.init()
        type = .summary
        infoTitle = "Total w/o Tax\nTax"
        
        total = order.orderAmount.amount.asCurrency()
        if order.orderAmount.state.count == 0 {
            info = "\(order.orderAmount.amountWithoutTax.asCurrency())\n\(order.orderAmount.tax.asCurrency())"
        } else {
            info = "\(order.orderAmount.amountWithoutTax.asCurrency())\n\(order.orderAmount.tax.asCurrency()) (\(order.orderAmount.state) State)"
        }
    }
}

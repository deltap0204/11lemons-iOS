//
//  AddOrderDetailsWhasNFoldVM.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/5/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

class AddOrderDetailsWhasNFoldVM: AddOrderDetailGarmentTypesVM {
    
    func getTotal(_ orderDetail: OrderDetail, order: Order) -> Double {
        guard orderDetail.service != nil else { return 0.0 }

        let subtotal = getSubTotal(orderDetail, order: order)
        
        if let tax = orderDetail.tax, tax != 0 {
            return subtotal * (1 + (tax / 100 ) )
        } else {
            return subtotal
        }
    }
    
    func getSubTotal(_ orderDetail: OrderDetail, order: Order) -> Double {
        guard orderDetail.service != nil else { return 0.0 }
        
        let singlePrice = orderDetail.pricePer!
        return singlePrice * (orderDetail.weight ?? 0.0)
    }
    
    func getTax(_ orderDetail: OrderDetail) -> Double {
        guard let tax = orderDetail.tax else { return 0.0 }
        
        return tax
    }
}




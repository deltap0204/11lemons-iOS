//
//  AddOrderDetailsMenShirtVM.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/5/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

class AddOrderDetailsMenShirtVM: AddOrderDetailGarmentTypesVM {
    
    func getTotal(_ orderDetail: OrderDetail, order: Order) -> Double {
        guard orderDetail.service != nil else { return 0.0 }

        let subtotal = getSubTotal(orderDetail, order: order)
        
        if orderDetail.tax != 0 {
            return subtotal * (1 + (orderDetail.tax! / 100 ) )
        } else {
            return subtotal
        }
    }
    
    func getSubTotal(_ orderDetail: OrderDetail, order: Order) -> Double {
        guard orderDetail.service != nil else { return 0.0 }
        
        var subtotal = 0.0
        let singlePrice = orderDetail.pricePer!
        
        if let categories = orderDetail.garment?.properties {
            categories.forEach { category in
                if let attributes = category.attributes {
                    attributes.forEach{ attribute in
                        if attribute.upchargeAmount == 0.0 {
                            if attribute.upchargeMarkup != 0.0 {
                                let perc = attribute.upchargeMarkup / 100
                                subtotal = subtotal + (perc * singlePrice)
                            }
                        } else {
                            subtotal = subtotal + attribute.upchargeAmount
                        }
                    }
                }
            }
        }
        
        if order.shirt == Shirt.Folded {
            subtotal = subtotal + 0.5
        }
        
        return subtotal + singlePrice
    }
    
    func getTax(_ orderDetail: OrderDetail) -> Double {
        guard let tax = orderDetail.tax else { return 0.0 }
        
        return tax
    }
}

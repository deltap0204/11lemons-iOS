//
//  OrderDetailGeneral.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 4/6/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation


open class OrderDetailGeneral {
    
    var id: Int
    var orderId: Int = 0
    var quantity: Int?
    var pricePer: Double?
    var priceWithoutTaxes: Double?
    var tax: Double?
    var total: Double?
    var subtotal: Double?
    var weight: Double?
    var service: Service?
    var garment: OrderGarment?
    
    var product: Product?
    
    init(id: Int) {
        self.id = id
    }
}


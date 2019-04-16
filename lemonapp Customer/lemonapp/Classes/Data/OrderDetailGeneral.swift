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
    init(id:Int, orderId: Int,
         quantity: Int?,
         pricePer: Double?,
         priceWithoutTaxes: Double?,
         tax: Double?,
         total: Double?,
         subtotal: Double?,
         weight: Double?,
         service: Service?,
         garment: OrderGarment?,
        product: Product?) {
        self.id = id
        self.orderId = orderId
        self.quantity = quantity
        self.pricePer = pricePer
        self.priceWithoutTaxes = priceWithoutTaxes
        self.tax = tax
        self.total = total
        self.subtotal = subtotal
        self.weight = weight
        self.service = service
        self.garment = garment
        self.product = product
    }
}


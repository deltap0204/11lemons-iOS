//
//  OrderDetailsReceipt.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 4/6/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation


final class OrderDetailsReceipt: OrderDetailGeneral {
    
    override init(id: Int) {
        super.init(id: id)
    }
    
    init(entity: OrderDetailsReceiptEntity) {
        super.init(id: entity.id, orderId: entity.orderId, quantity: entity.quantity.value, pricePer: entity.pricePer.value, priceWithoutTaxes: entity.priceWithoutTaxes.value, tax: entity.tax.value, total: entity.total.value, subtotal: entity.subtotal.value, weight: entity.weight.value, service: entity.service.map {Service(entity: $0)}, garment: entity.garment.map { OrderGarment(entity: $0) }, product: entity.product.map { Product(entity: $0) })
    }
}


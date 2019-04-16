//
//  OrderDetailEntity.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//


import Foundation
import RealmSwift
public class OrderDetailEntity: Object {
    @objc dynamic var jsonOrder :OrderDetailsReceiptEntity? = nil
    override public static func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var id = 0
    @objc dynamic var orderId: Int = 0
    let quantity = RealmOptional<Int>()
    let pricePer = RealmOptional<Double>()
    let priceWithoutTaxes = RealmOptional<Double>()
    let tax = RealmOptional<Double>()
    let total = RealmOptional<Double>()
    let subtotal = RealmOptional<Double>()
    let weight = RealmOptional<Double>()
    @objc dynamic var service: ServiceEntity? = nil
    @objc dynamic var garment: OrderGarmentEntity? = nil
    @objc dynamic var product: ProductEntity? = nil
    
    static func create(with orderDetail: OrderDetail) -> OrderDetailEntity {
        var orderDetailEntity = OrderDetailEntity()
        orderDetailEntity.id = orderDetail.id
        orderDetailEntity.orderId =  orderDetail.orderId
        orderDetailEntity.quantity.value =  orderDetail.quantity
        orderDetailEntity.pricePer.value =  orderDetail.pricePer
        orderDetailEntity.priceWithoutTaxes.value =  orderDetail.priceWithoutTaxes
        orderDetailEntity.tax.value =  orderDetail.tax
        orderDetailEntity.total.value = orderDetail.total
        orderDetailEntity.subtotal.value = orderDetail.subtotal
        orderDetailEntity.weight.value = orderDetail.weight
        if let service = orderDetail.service {
            orderDetailEntity.service = ServiceEntity.create(with: service)
        } else {
            orderDetailEntity.service = nil
        }
        
        if let garment = orderDetail.garment {
            orderDetailEntity.garment = OrderGarmentEntity.create(with: garment)
        } else {
            orderDetailEntity.garment = nil
        }
        
        
        if let product = orderDetail.product {
            orderDetailEntity.product = ProductEntity.create(with: product)
        } else {
            orderDetailEntity.product = nil
        }
        return orderDetailEntity
    }
}


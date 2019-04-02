//
//  OrderDetailsReceiptEntity.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//

import Foundation
import RealmSwift
public class OrderDetailsReceiptEntity: Object, RealmOptionalType {
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
}

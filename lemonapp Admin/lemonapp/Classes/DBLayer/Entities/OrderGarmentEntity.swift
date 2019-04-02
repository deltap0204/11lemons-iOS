//
//  OrderGarmentEntity.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//


import Foundation
import RealmSwift
public class OrderGarmentEntity: Object, RealmOptionalType {
    override public static func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var id = 0
    @objc dynamic var orderId = 0
    let properties = List<CategoryEntity>()
    
    static func create(with orderGarment: OrderGarment) -> OrderGarmentEntity {
        let orderGarmentEntity = OrderGarmentEntity()
        orderGarmentEntity.id = orderGarment.id
        orderGarmentEntity.orderId = orderGarment.orderId
        orderGarmentEntity.properties.removeAll()
        let newProperties = orderGarment.properties?.compactMap { CategoryEntity.create(with: $0)} ?? []
        orderGarmentEntity.properties.append(objectsIn: newProperties)
        return orderGarmentEntity
    }
}


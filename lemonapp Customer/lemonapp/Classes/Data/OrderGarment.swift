//
//  OrderGarment.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


final class OrderGarment {
    
    var id: Int
    var orderId: Int = 0
    var properties: [Category]?
    
    init(id: Int) {
        self.id = id
    }

    init(entity: OrderGarmentEntity) {
        self.id = entity.id
        self.orderId = entity.orderId
        self.properties = entity.properties.flatMap({Category(entity: $0)})
    }
    
    func sync(_ orderGarment: OrderGarment) {
        orderId = orderGarment.orderId
        properties = orderGarment.properties
    }
}

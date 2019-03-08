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

//    func syncDataModel() {
//        _dataModel.id = NSNumber(value: id as Int)
//        _dataModel.orderid = NSNumber(value: orderId as Int)
//
//        properties?.forEach {
//            if let categoryModel = $0.dataModel as? CategoryModel, !_dataModel.properties.contains(categoryModel) {
//                if let exist = try? LemonCoreDataManager.fetch(CategoryModel.self).contains(categoryModel) {
//                    if !exist {
//                        LemonCoreDataManager.insert(false, objects: categoryModel)
//                    }
//                }
//                _dataModel.properties.insert(categoryModel)
//            }
//        }
//    }

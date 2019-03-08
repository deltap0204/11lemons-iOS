//
//  OrderGarment.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class OrderGarment {
    
    var id: Int
    var orderId: Int = 0
    var properties: [Category]?
    
    fileprivate var _dataModel: OrderGarmentModel = OrderGarmentModel()
    
    init(id: Int) {
        self.id = id
    }
    
    convenience init(orderGarmentModel: OrderGarmentModel) {
        self.init(id: orderGarmentModel.id.intValue)
        orderId = orderGarmentModel.orderid.intValue
        properties = orderGarmentModel.properties.map { Category(categoryModel: $0) }
        _dataModel = orderGarmentModel
    }
    
    func sync(_ orderGarment: OrderGarment) {
        orderId = orderGarment.orderId
        properties = orderGarment.properties
        syncDataModel()
    }
}

extension OrderGarment: DataModelWrapper {
    
    var dataModel: NSManagedObject {
        return _dataModel
    }
    
    func syncDataModel() {
        _dataModel.id = NSNumber(value: id as Int)
        _dataModel.orderid = NSNumber(value: orderId as Int)

        properties?.forEach {
            if let categoryModel = $0.dataModel as? CategoryModel, !_dataModel.properties.contains(categoryModel) {
                if let exist = try? LemonCoreDataManager.fetch(CategoryModel.self).contains(categoryModel) {
                    if !exist {
                        LemonCoreDataManager.insert(false, objects: categoryModel)
                    }
                }
                _dataModel.properties.insert(categoryModel)
            }
        }
    }
}

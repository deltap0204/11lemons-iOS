//
//  OrderImages.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class OrderImages {
    
    var id: Int
    var orderID: Int = 0
    var imageURL: String = ""
    
    fileprivate var _dataModel: OrderImagesModel = OrderImagesModel()
    
    init(id: Int) {
        self.id = id
    }
    
    convenience init(orderImagesModel: OrderImagesModel) {
        self.init(id: orderImagesModel.id.intValue)
        orderID = orderImagesModel.orderID.intValue
        imageURL = orderImagesModel.imageURL
        _dataModel = orderImagesModel
    }
    
    func sync(_ orderImages: OrderImages) {
        orderID = orderImages.orderID
        imageURL = orderImages.imageURL
        syncDataModel()
    }
}

extension OrderImages: DataModelWrapper {
    
    var dataModel: NSManagedObject {
        return _dataModel
    }
    
    func syncDataModel() {
        _dataModel.id = NSNumber(value: id as Int)
        _dataModel.orderID = NSNumber(value: orderID as Int)
        _dataModel.imageURL = imageURL
    }
}

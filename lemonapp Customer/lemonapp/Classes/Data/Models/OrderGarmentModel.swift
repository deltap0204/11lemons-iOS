//
//  OrderGarmentModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class OrderGarmentModel: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var orderid: NSNumber
    @NSManaged var properties: Set<CategoryModel>
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init () {
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: LemonCoreDataManager.context)!
        self.init(entity: entity, insertInto: nil)
    }
    
    convenience init (context: NSManagedObjectContext = LemonCoreDataManager.context,
                      id: NSNumber, orderid: NSNumber, properties: Set<CategoryModel>) {
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: context)!
        self.init(entity: entity, insertInto: nil)
        self.id = id
        self.orderid = orderid
        self.properties = properties
    }
}

extension OrderGarmentModel: ModelNameProvider {
    class var modelName: String { return "OrderGarment" }
}

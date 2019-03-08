//
//  ProductModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class ProductModel: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var name: String
    @NSManaged var descr: String
    @NSManaged var isActive: Bool
    @NSManaged var price: NSNumber
    @NSManaged var taxable: Bool
    @NSManaged var useWeight: Bool
    @NSManaged var parentId: NSNumber
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init (context: NSManagedObjectContext = LemonCoreDataManager.context,
        id: NSNumber,
        name: String,
        description: String,
        isActive: Bool,
        price: NSNumber,
        taxable: Bool,
        useWeight: Bool,
        parentId: NSNumber) {
            let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: context)!
            self.init(entity: entity, insertInto: nil)
            
            self.id = id
            self.name = name
            self.descr = description
            self.isActive = isActive
            self.price = price
            self.taxable = taxable
            self.useWeight = useWeight
            self.parentId = parentId
    }
}

extension ProductModel: ModelNameProvider {
    class var modelName: String { return "Product" }
}

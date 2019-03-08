//
//  OrderImagesModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class OrderImagesModel: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var orderID: NSNumber
    @NSManaged var imageURL: String
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init () {
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: LemonCoreDataManager.context)!
        self.init(entity: entity, insertInto: nil)
    }
    
    convenience init (context: NSManagedObjectContext = LemonCoreDataManager.context, id: NSNumber, orderID: NSNumber, imageURL: String) {
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: context)!
        self.init(entity: entity, insertInto: nil)
        self.id = id
        self.orderID = orderID
        self.imageURL = imageURL
    }
}

extension OrderImagesModel: ModelNameProvider {
    class var modelName: String { return "OrderImages" }
}

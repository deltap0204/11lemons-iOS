//
//  DeliveryPricingModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class DeliveryPricingModel: NSManagedObject {
    
    @NSManaged var type: NSNumber
    @NSManaged var amount: NSNumber
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init (context: NSManagedObjectContext = LemonCoreDataManager.context,
        type: Int,
        amount: Double) {
            let entity = NSEntityDescription.entity(forEntityName: DeliveryPricingModel.modelName, in: context)!
            self.init(entity: entity, insertInto: nil)
            self.type = NSNumber(value: type as Int)
            self.amount = NSNumber(value: amount as Double)
    }
}

extension DeliveryPricingModel: ModelNameProvider {
    class var modelName: String { return "DeliveryPricing" }
}

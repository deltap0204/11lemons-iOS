//
//  GarmentTypeModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import CoreData

final class GarmentTypeModel: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var type: String?
    @NSManaged var descr: String?

    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init () {
        let entity = NSEntityDescription.entity(forEntityName: GarmentTypeModel.modelName, in: LemonCoreDataManager.context)!
        self.init(entity: entity, insertInto: nil)
    }
}

extension GarmentTypeModel: ModelNameProvider {
    class var modelName: String { return "GarmentType" }
}

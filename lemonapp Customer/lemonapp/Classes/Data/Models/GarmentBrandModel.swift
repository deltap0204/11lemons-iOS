//
//  GarmentBrandModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import CoreData

final class GarmentBrandModel: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var name: String?
    @NSManaged var descr: String?
    
    @NSManaged var garments: Set<GarmentModel>
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init () {
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: LemonCoreDataManager.context)!
        self.init(entity: entity, insertInto: nil)
    }
}

extension GarmentBrandModel: ModelNameProvider {
    class var modelName: String { return "GarmentBrand" }
}

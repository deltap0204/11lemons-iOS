//
//  GarmentModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import CoreData

final class GarmentModel: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var descr: String?
    @NSManaged var imageName: String?
    @NSManaged var userId: NSNumber
    @NSManaged var viewed: Bool
    
    @NSManaged var type: GarmentTypeModel?
    @NSManaged var brand: GarmentBrandModel?
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init () {
        let entity = NSEntityDescription.entity(forEntityName: GarmentModel.modelName, in: LemonCoreDataManager.context)!
        self.init(entity: entity, insertInto: nil)
    }
}

extension GarmentModel: ModelNameProvider {
    class var modelName: String { return "Garment" }
}

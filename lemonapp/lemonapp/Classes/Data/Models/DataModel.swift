//
//  DataModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

class DataModel: NSManagedObject, ModelNameProvider {
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init (context: NSManagedObjectContext = LemonCoreDataManager.context) {
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: context)!
        self.init(entity: entity, insertInto: nil)
    }
    
    class var modelName: String { return "" }
}

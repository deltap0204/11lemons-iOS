//
//  AddressModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class AddressModel: NSManagedObject {
    
    @NSManaged var id: NSNumber?
    @NSManaged var street: String
    @NSManaged var aptSuite: String
    @NSManaged var city: String
    @NSManaged var state: String
    @NSManaged var zip: String
    @NSManaged var label: String
    @NSManaged var removed: Bool
    @NSManaged var userId: NSNumber
    @NSManaged var notes: String?
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    
    convenience init (context: NSManagedObjectContext = LemonCoreDataManager.context,
        id: Int?,
        street: String,
        aptSuite: String,
        city: String,
        state: String,
        zip: String,
        label: String,
        removed: Bool,
        userId: Int,
        notes: String? = nil) {
            
            let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: context)!
            self.init(entity: entity, insertInto: nil)
            
            self.id = id == nil ? nil : NSNumber(value: id! as Int)
            self.street = street
            self.aptSuite = aptSuite
            self.city = city
            self.state = state
            self.zip = zip
            self.label = label
            self.removed = removed
            self.userId = NSNumber(value: userId as Int)
            self.notes = notes
    }
}

extension AddressModel: ModelNameProvider {
    class var modelName: String { return "Address" }
}

//
//  WalletTransitionModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import CoreData

final class WalletTransitionModel: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var date: Date?
    @NSManaged var amount: NSNumber
    @NSManaged var reason: String?
    @NSManaged var notes: String?
    @NSManaged var userId: NSNumber
    @NSManaged var type: NSNumber?
    @NSManaged var viewed: Bool
    @NSManaged var archived: Bool
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init () {
        let entity = NSEntityDescription.entity(forEntityName: WalletTransitionModel.modelName, in: LemonCoreDataManager.context)!
        self.init(entity: entity, insertInto: nil)
    }
}

extension WalletTransitionModel: ModelNameProvider {
    class var modelName: String { return "WalletTransition" }
}

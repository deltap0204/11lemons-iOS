//
//  PaymentCardModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class PaymentCardModel: NSManagedObject {
    
    @NSManaged var id: NSNumber?
    @NSManaged var type: String
    @NSManaged var number: String
    @NSManaged var expiration: String?
    @NSManaged var removed: Bool
    @NSManaged var userId: NSNumber
    @NSManaged var token: String?
    @NSManaged var zip: String?
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init (context: NSManagedObjectContext = LemonCoreDataManager.context,
                      id: Int?,
                      number: String,
                      expiration: String?,
                      type: String,
                      removed: Bool,
                      userId: Int,
                      token: String?,
                      zip: String?) {
        
        //let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: context)!
        let entity = NSEntityDescription.entity(forEntityName: PaymentCardModel.modelName, in: context)!
        self.init(entity: entity, insertInto: nil)
        
        if let idInt = id {
            self.id = NSNumber(value: idInt as Int)
        }
        //self.id = id == nil ? id : NSNumber(value: id! as Int)
        self.number = number
        self.expiration = expiration
        self.type = type
        self.removed = removed
        self.userId = NSNumber(value: userId as Int)
        self.token = token
        self.zip = zip
    }
}

extension PaymentCardModel: ModelNameProvider {
    class var modelName: String { return "PaymentCard" }
}

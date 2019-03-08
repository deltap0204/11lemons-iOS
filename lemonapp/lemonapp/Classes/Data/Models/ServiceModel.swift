//
//  ServiceModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class ServiceModel: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var name: String
    @NSManaged var descr: String
    @NSManaged var active: Bool
    @NSManaged var taxable: Bool
    @NSManaged var isBeta: Bool
    @NSManaged var rate: NSNumber
    @NSManaged var price: NSNumber
    @NSManaged var priceBasedOn: String
    @NSManaged var isSelected: Bool
    @NSManaged var parentID: NSNumber
    @NSManaged var activeImage: String
    @NSManaged var inactiveImage: String
    @NSManaged var typesOfService: Set<ServiceModel>
    @NSManaged var unitType: String
    @NSManaged var roundPriceNearest: NSNumber
    @NSManaged var roundPrice: Bool
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init () {
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: LemonCoreDataManager.context)!
        self.init(entity: entity, insertInto: nil)
    }
    
    convenience init (context: NSManagedObjectContext = LemonCoreDataManager.context,
                      id: NSNumber, name: String, descr: String, active: Bool, taxable: Bool, isBeta: Bool, rate: NSNumber, price: NSNumber, priceBasedOn: String, isSelected: Bool, parentID: NSNumber, activeImage: String, inactiveImage: String, typesOfService: Set<ServiceModel>, unitType: String, roundPriceNearest: NSNumber, roundPrice: Bool) {
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: context)!
        self.init(entity: entity, insertInto: nil)
        self.id = id
        self.name = name
        self.descr = descr
        self.active = active
        self.taxable = taxable
        self.isBeta = isBeta
        self.rate = rate
        self.price = price
        self.priceBasedOn = priceBasedOn
        self.isSelected = isSelected
        self.parentID = parentID
        self.activeImage = activeImage
        self.inactiveImage = inactiveImage
        self.typesOfService = typesOfService
        self.unitType = unitType
        self.roundPriceNearest = roundPriceNearest
        self.roundPrice = roundPrice
    }
}

extension ServiceModel: ModelNameProvider {
    class var modelName: String { return "Service" }
}

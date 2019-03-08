//
//  CategoryModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class CategoryModel: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var name: String
    @NSManaged var descr: String
    @NSManaged var active: Bool
    @NSManaged var maxAllowed: NSNumber?
    @NSManaged var required: Bool
    @NSManaged var image: String
    @NSManaged var itemizeOnReceipt: Bool
    @NSManaged var allowMultipleValues: Bool
    @NSManaged var temporaryAttribute: Bool
    @NSManaged var singleProduct: Bool
    @NSManaged var pounds: Bool
    @NSManaged var dollars: Bool
    @NSManaged var months: Bool
    @NSManaged var hours: Bool
    @NSManaged var other: Bool
    @NSManaged var isDelet: Bool
    @NSManaged var attributes: Set<AttributeModel>
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init () {
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: LemonCoreDataManager.context)!
        self.init(entity: entity, insertInto: nil)
    }
    
    convenience init (context: NSManagedObjectContext = LemonCoreDataManager.context,
                      id: NSNumber, name: String, descr: String, active: Bool, maxAllowed: NSNumber?,
                      required: Bool?, image: String, itemizeOnReceipt: Bool?, allowMultipleValues: Bool?,
                      temporaryAttribute: Bool?, singleProduct: Bool, pounds: Bool, dollars: Bool,
                      months: Bool, hours: Bool, other: Bool, isDelet: Bool, attributes: Set<AttributeModel>) {
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: context)!
        self.init(entity: entity, insertInto: nil)
        self.id = id
        self.name = name
        self.descr = descr
        self.active = active
        self.maxAllowed = maxAllowed
        self.required = required ?? false
        self.image = image
        self.itemizeOnReceipt = itemizeOnReceipt ?? false
        self.allowMultipleValues = allowMultipleValues ?? false
        self.temporaryAttribute = temporaryAttribute ?? false
        self.singleProduct = singleProduct
        self.pounds = pounds
        self.dollars = dollars
        self.months = months
        self.hours = hours
        self.other = other
        self.isDelet = isDelet
        self.attributes = attributes
    }
}

extension CategoryModel: ModelNameProvider {
    class var modelName: String { return "Category" }
}

//
//  AttributeModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class AttributeModel: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var attributeName: String
    @NSManaged var categoryId: NSNumber
    @NSManaged var price: NSNumber
    @NSManaged var oneTimeUse: Bool
    @NSManaged var oneTimeUseProcessed: Bool
    @NSManaged var descr: String
    @NSManaged var image: String
    @NSManaged var percentUpcharge: Bool
    @NSManaged var roundPriceNearest: String
    @NSManaged var displayReceipt: Bool
    @NSManaged var displayPriceList: Bool
    @NSManaged var unitType: String
    @NSManaged var pieces: NSNumber
    @NSManaged var taxable: Bool
    @NSManaged var upcharge: Bool
    @NSManaged var dollarUpcharge: Bool
    @NSManaged var itemizeOnReceipt: Bool
    @NSManaged var roundPrice: Bool
    @NSManaged var alwaysRoundUp: Bool
    @NSManaged var upchargeAmount: NSNumber
    @NSManaged var attributeCategory: String
    @NSManaged var isSelected: Bool
    @NSManaged var upchargeMarkup: NSNumber
    @NSManaged var inactiveImage: String
    @NSManaged var activeImage: String
    @NSManaged var isDelet: Bool
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init () {
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: LemonCoreDataManager.context)!
        self.init(entity: entity, insertInto: nil)
    }
    
    convenience init (context: NSManagedObjectContext = LemonCoreDataManager.context,
                      id: NSNumber, attributeName: String, categoryId: NSNumber, price: NSNumber, oneTimeUse: Bool, oneTimeUseProcessed: Bool,
                      descr: String, image: String, percentUpcharge: Bool, roundPriceNearest: String, displayReceipt: Bool, displayPriceList: Bool,
                      unitType: String, pieces: NSNumber, taxable: Bool, upcharge: Bool, dollarUpcharge: Bool, itemizeOnReceipt: Bool, roundPrice: Bool,
                      alwaysRoundUp: Bool, upchargeAmount: NSNumber, attributeCategory: String, isSelected: Bool, upchargeMarkup: NSNumber, inactiveImage: String, activeImage: String, isDelet: Bool) {
        
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: context)!
        self.init(entity: entity, insertInto: nil)
        self.id = id
        self.attributeName = attributeName
        self.categoryId = categoryId
        self.price = price
        self.oneTimeUse = oneTimeUse
        self.oneTimeUseProcessed = oneTimeUseProcessed
        self.descr = descr
        self.image = image
        self.percentUpcharge = percentUpcharge
        self.roundPriceNearest = roundPriceNearest
        self.displayReceipt = displayReceipt
        self.displayPriceList = displayPriceList
        self.unitType = unitType
        self.pieces = pieces
        self.taxable = taxable
        self.upcharge = upcharge
        self.dollarUpcharge = dollarUpcharge
        self.itemizeOnReceipt = itemizeOnReceipt
        self.roundPrice = roundPrice
        self.alwaysRoundUp = alwaysRoundUp
        self.upchargeAmount = upchargeAmount
        self.attributeCategory = attributeCategory
        self.isSelected = isSelected
        self.upchargeMarkup = upchargeMarkup
        self.inactiveImage = inactiveImage
        self.activeImage = activeImage
        self.isDelet = isDelet
    }
}

extension AttributeModel: ModelNameProvider {
    class var modelName: String { return "Attribute" }
}

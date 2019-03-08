//
//  Attribute.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class Attribute {
    
    var id: Int
    var attributeName: String = ""
    var categoryId: Int = 0
    var price: Double = 0.0
    var oneTimeUse: Bool = false
    var oneTimeUseProcessed: Bool = false
    var description: String = ""
    var image: String = ""
    var percentUpcharge: Bool = false
    var roundPriceNearest: String = ""
    var displayReceipt: Bool = false
    var displayPriceList: Bool = false
    var unitType: String = ""
    var pieces: Int = 0
    var taxable: Bool = false
    var upcharge: Bool = false
    var dollarUpcharge: Bool = false
    var itemizeOnReceipt: Bool = false
    var roundPrice: Bool = false
    var alwaysRoundUp: Bool = false
    var upchargeAmount: Double = 0.0
    var attributeCategory: String = ""
    var isSelected: Bool = false
    var upchargeMarkup: Double = 0.0
    var inactiveImage: String = ""
    var activeImage: String = ""
    var deleted: Bool = false
    
    fileprivate var _dataModel: AttributeModel = AttributeModel()
    
    init(id: Int) {
        self.id = id
    }
    
    convenience init(attributeModel: AttributeModel) {
        self.init(id: attributeModel.id.intValue)
        attributeName = attributeModel.attributeName
        categoryId = attributeModel.categoryId.intValue
        price = attributeModel.price.doubleValue
        oneTimeUse = attributeModel.oneTimeUse
        oneTimeUseProcessed = attributeModel.oneTimeUseProcessed
        description = attributeModel.descr
        image = attributeModel.image
        percentUpcharge = attributeModel.percentUpcharge
        roundPriceNearest = attributeModel.roundPriceNearest
        displayReceipt = attributeModel.displayReceipt
        displayPriceList = attributeModel.displayPriceList
        unitType = attributeModel.unitType
        pieces = attributeModel.pieces.intValue
        taxable = attributeModel.taxable
        upcharge = attributeModel.upcharge
        dollarUpcharge = attributeModel.dollarUpcharge
        itemizeOnReceipt = attributeModel.itemizeOnReceipt
        roundPrice = attributeModel.roundPrice
        alwaysRoundUp = attributeModel.alwaysRoundUp
        upchargeAmount = attributeModel.upchargeAmount.doubleValue
        attributeCategory = attributeModel.attributeCategory
        isSelected = attributeModel.isSelected
        upchargeMarkup = attributeModel.upchargeMarkup.doubleValue
        inactiveImage = attributeModel.inactiveImage
        activeImage = attributeModel.activeImage
        deleted = attributeModel.isDelet
        _dataModel = attributeModel
        
    }
    
    func sync(_ attribute: Attribute) {
        attributeName = attribute.attributeName
        categoryId = attribute.categoryId
        price = attribute.price
        oneTimeUse = attribute.oneTimeUse
        oneTimeUseProcessed = attribute.oneTimeUseProcessed
        description = attribute.description
        image = attribute.image
        percentUpcharge = attribute.percentUpcharge
        roundPriceNearest = attribute.roundPriceNearest
        displayReceipt = attribute.displayReceipt
        displayPriceList = attribute.displayPriceList
        unitType = attribute.unitType
        pieces = attribute.pieces
        taxable = attribute.taxable
        upcharge = attribute.upcharge
        dollarUpcharge = attribute.dollarUpcharge
        itemizeOnReceipt = attribute.itemizeOnReceipt
        roundPrice = attribute.roundPrice
        alwaysRoundUp = attribute.alwaysRoundUp
        upchargeAmount = attribute.upchargeAmount
        attributeCategory = attribute.attributeCategory
        isSelected = attribute.isSelected
        upchargeMarkup = attribute.upchargeMarkup
        inactiveImage = attribute.inactiveImage
        activeImage = attribute.activeImage
        deleted = attribute.deleted
        syncDataModel()
    }
}

extension Attribute: DataModelWrapper {
    
    var dataModel: NSManagedObject {
        return _dataModel
    }
    
    func syncDataModel() {
        _dataModel.id = NSNumber(value: id as Int)
        _dataModel.attributeName = attributeName
        _dataModel.categoryId = NSNumber(value: categoryId as Int)
        _dataModel.price = NSNumber(value: price as Double)
        _dataModel.oneTimeUse = oneTimeUse
        _dataModel.oneTimeUseProcessed = oneTimeUseProcessed
        _dataModel.descr = description
        _dataModel.image = image
        _dataModel.percentUpcharge = percentUpcharge
        _dataModel.roundPriceNearest = roundPriceNearest
        _dataModel.displayReceipt = displayReceipt
        _dataModel.displayPriceList = displayPriceList
        _dataModel.unitType = unitType
        _dataModel.pieces = NSNumber(value: pieces as Int)
        _dataModel.taxable = taxable
        _dataModel.upcharge = upcharge
        _dataModel.dollarUpcharge = dollarUpcharge
        _dataModel.itemizeOnReceipt = itemizeOnReceipt
        _dataModel.roundPrice = roundPrice
        _dataModel.alwaysRoundUp = alwaysRoundUp
        _dataModel.upchargeAmount = NSNumber(value: upchargeAmount as Double)
        _dataModel.attributeCategory = attributeCategory
        _dataModel.isSelected = isSelected
        _dataModel.upchargeMarkup = NSNumber(value: upchargeMarkup as Double)
        _dataModel.inactiveImage = inactiveImage
        _dataModel.activeImage = activeImage
        _dataModel.isDelet = deleted
    }
}

extension Attribute: Equatable {
    static func == (lhs: Attribute, rhs: Attribute) -> Bool {
        return lhs.id == rhs.id
    }
}

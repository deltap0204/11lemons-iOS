//
//  Attribute.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


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
    
    init(id: Int) {
        self.id = id
    }

    init(entity: AttributeEntity) {
        self.id = entity.id
        self.attributeName = entity.attributeName
        self.categoryId = entity.categoryId
        self.price = entity.price
        self.oneTimeUse = entity.oneTimeUse
        self.oneTimeUseProcessed = entity.oneTimeUseProcessed
        self.description = entity.descriptions
        self.image = entity.image
        self.percentUpcharge = entity.percentUpcharge
        self.roundPriceNearest = entity.roundPriceNearest
        self.displayReceipt = entity.displayReceipt
        self.displayPriceList = entity.displayPriceList
        self.unitType = entity.unitType
        self.pieces = entity.pieces
        self.taxable = entity.taxable
        self.upcharge = entity.upcharge
        self.dollarUpcharge = entity.dollarUpcharge
        self.itemizeOnReceipt = entity.itemizeOnReceipt
        self.roundPrice = entity.roundPrice
        self.alwaysRoundUp = entity.alwaysRoundUp
        self.upchargeAmount = entity.upchargeAmount
        self.attributeCategory = entity.attributeCategory
        self.isSelected = entity.isSelected
        self.upchargeMarkup = entity.upchargeMarkup
        self.inactiveImage = entity.inactiveImage
        self.activeImage = entity.activeImage
        self.deleted = entity.deleted
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
    }
}

extension Attribute: Equatable {
    static func == (lhs: Attribute, rhs: Attribute) -> Bool {
        return lhs.id == rhs.id
    }
}

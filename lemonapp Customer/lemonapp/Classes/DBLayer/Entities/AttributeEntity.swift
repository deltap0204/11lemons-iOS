//
//  AttributeEntity.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//


import Foundation
import RealmSwift
public class AttributeEntity: Object, RealmOptionalType {
    @objc dynamic var id = 0
    @objc dynamic var attributeName = ""
    @objc dynamic var categoryId = 0
    @objc dynamic var price: Double = 0.0
    @objc dynamic var oneTimeUse = false
    @objc dynamic var oneTimeUseProcessed = false
    @objc dynamic var descriptions = ""
    @objc dynamic var image = ""
    @objc dynamic var percentUpcharge = false
    @objc dynamic var roundPriceNearest = ""
    @objc dynamic var displayReceipt = false
    @objc dynamic var displayPriceList = false
    @objc dynamic var unitType = ""
    @objc dynamic var pieces = 0
    @objc dynamic var taxable = false
    @objc dynamic var upcharge = false
    @objc dynamic var dollarUpcharge = false
    @objc dynamic var itemizeOnReceipt = false
    @objc dynamic var roundPrice = false
    @objc dynamic var alwaysRoundUp = false
    @objc dynamic var upchargeAmount: Double = 0.0
    @objc dynamic var attributeCategory = ""
    @objc dynamic var isSelected = false
    @objc dynamic var upchargeMarkup: Double = 0.0
    @objc dynamic var inactiveImage = ""
    @objc dynamic var activeImage = ""
    @objc dynamic var deleted = false
    
    static func create(with attribute: Attribute) -> AttributeEntity {
        let attributeEntity = AttributeEntity()
        attributeEntity.id = attribute.id
        attributeEntity.attributeName = attribute.attributeName
        attributeEntity.categoryId = attribute.categoryId
        attributeEntity.price = attribute.price
        attributeEntity.oneTimeUse = attribute.oneTimeUse
        attributeEntity.oneTimeUseProcessed = attribute.oneTimeUseProcessed
        attributeEntity.descriptions = attribute.description
        attributeEntity.image = attribute.image
        attributeEntity.percentUpcharge = attribute.percentUpcharge
        attributeEntity.roundPriceNearest = attribute.roundPriceNearest
        attributeEntity.displayReceipt = attribute.displayReceipt
        attributeEntity.displayPriceList = attribute.displayPriceList
        attributeEntity.unitType = attribute.unitType
        attributeEntity.pieces = attribute.pieces
        attributeEntity.taxable = attribute.taxable
        attributeEntity.upcharge = attribute.upcharge
        attributeEntity.dollarUpcharge = attribute.dollarUpcharge
        attributeEntity.itemizeOnReceipt = attribute.itemizeOnReceipt
        attributeEntity.roundPrice = attribute.roundPrice
        attributeEntity.alwaysRoundUp = attribute.alwaysRoundUp
        attributeEntity.upchargeAmount = attribute.upchargeAmount
        attributeEntity.attributeCategory = attribute.attributeCategory
        attributeEntity.isSelected = attribute.isSelected
        attributeEntity.upchargeMarkup = attribute.upchargeMarkup
        attributeEntity.inactiveImage = attribute.inactiveImage
        attributeEntity.activeImage = attribute.activeImage
        attributeEntity.deleted = attribute.deleted
        return attributeEntity
    }
}





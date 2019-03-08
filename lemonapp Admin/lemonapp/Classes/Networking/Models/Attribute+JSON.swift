//
//  Attribute+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON


extension Attribute: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> Attribute {
        let id = j["ID"].intValue
        let attribute = Attribute(id: id)
        
        attribute.attributeName = j["AttributeName"].stringValue
        attribute.categoryId = j["CategoryID"].intValue
        attribute.price = j["Price"].doubleValue
        attribute.oneTimeUse = j["OneTimeUse"].boolValue
        attribute.oneTimeUseProcessed = j["OneTimeUseProcessed"].boolValue
        attribute.description = j["Description"].stringValue
        attribute.image = j["Image"].stringValue
        attribute.percentUpcharge = j["PercentUpcharge"].boolValue
        attribute.roundPriceNearest = j["RoundPriceNearest"].stringValue
        attribute.displayReceipt = j["DisplayReceipt"].boolValue
        attribute.displayPriceList = j["DisplayPriceList"].boolValue
        attribute.unitType = j["UnitType"].stringValue
        attribute.pieces = j["Pieces"].intValue
        attribute.taxable = j["Taxable"].boolValue
        attribute.upcharge = j["Upcharge"].boolValue
        attribute.dollarUpcharge = j["DollarUpcharge"].boolValue
        attribute.itemizeOnReceipt = j["ItemizeOnReceipt"].boolValue
        attribute.roundPrice = j["RoundPrice"].boolValue
        attribute.alwaysRoundUp = j["AlwaysRoundUp"].boolValue
        attribute.upchargeAmount = j["UpchargeAmount"].doubleValue
        attribute.attributeCategory = j["AttributeCategory"].stringValue
        attribute.isSelected = j["IsSelected"].boolValue
        attribute.upchargeMarkup = j["UpchargeMarkup"].doubleValue
        attribute.inactiveImage = j["InactiveImage"].stringValue
        attribute.activeImage = j["ActiveImage"].stringValue
        attribute.deleted = j["Deleted"].boolValue
        return attribute
    }
}

extension Attribute: Encodable {
    
    func encode() -> [String : AnyObject] {
        var returnArray: [String : AnyObject] = [:]
        
        returnArray["ID"] = id as AnyObject
        returnArray["AttributeName"] = attributeName as AnyObject
        returnArray["CategoryID"] = categoryId as AnyObject
        returnArray["Price"] = price as AnyObject
        returnArray["OneTimeUse"] = oneTimeUse as AnyObject
        returnArray["OneTimeUseProcessed"] = oneTimeUseProcessed as AnyObject
        returnArray["Description"] = description as AnyObject
        returnArray["Image"] = image as AnyObject
        returnArray["PercentUpcharge"] = percentUpcharge as AnyObject
        returnArray["RoundPriceNearest"] = roundPriceNearest as AnyObject
        returnArray["DisplayReceipt"] = displayReceipt as AnyObject
        returnArray["DisplayPriceList"] = displayPriceList as AnyObject
        returnArray["UnitType"] = unitType as AnyObject
        returnArray["Pieces"] = pieces as AnyObject
        returnArray["Taxable"] = taxable as AnyObject
        returnArray["Upcharge"] = upcharge as AnyObject
        returnArray["DollarUpcharge"] = dollarUpcharge as AnyObject
        returnArray["ItemizeOnReceipt"] = itemizeOnReceipt as AnyObject
        returnArray["RoundPrice"] = roundPrice as AnyObject
        returnArray["AlwaysRoundUp"] = alwaysRoundUp as AnyObject
        returnArray["UpchargeAmount"] = upchargeAmount as AnyObject
        returnArray["AttributeCategory"] = attributeCategory as AnyObject
        returnArray["IsSelected"] = isSelected as AnyObject
        returnArray["UpchargeMarkup"] = upchargeMarkup as AnyObject
        returnArray["InactiveImage"] = inactiveImage as AnyObject
        returnArray["ActiveImage"] = activeImage as AnyObject
        returnArray["Deleted"] = deleted as AnyObject
        
        return returnArray
    }
    
}

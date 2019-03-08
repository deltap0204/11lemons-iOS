//
//  Category+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON


extension Category: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> Category {
        let id = j["Id"].intValue
        let category = Category(id: id)
        
        category.name = j["Name"].stringValue
        category.description = j["Description"].stringValue
        category.active = j["Active"].boolValue
        category.maxAllowed = j["MaxAllowed"].intValue
        category.required = j["Required"].boolValue
        category.image = j["Image"].stringValue
        category.itemizeOnReceipt = j["ItemizeOnReceipt"].boolValue
        category.allowMultipleValues = j["AllowMultipleValues"].boolValue
        category.temporaryAttribute = j["TemporaryAttribute"].boolValue
        category.singleProduct = j["SingleProduct"].boolValue
        category.pounds = j["Pounds"].boolValue
        category.dollars = j["Dollars"].boolValue
        category.months = j["Months"].boolValue
        category.hours = j["Hours"].boolValue
        category.other = j["Other"].boolValue
        category.deleted = j["Deleted"].boolValue
        let attributes = try j["Attributes"].arrayValue.flatMap { try Attribute.decode($0) }
        category.attributes = attributes

        return category
    }
}

extension Category: Encodable {
    
    func encode() -> [String : AnyObject] {
        var returnArray: [String : AnyObject] = [:]

        returnArray["Name"] = name as AnyObject
        returnArray["Description"] = description as AnyObject
        returnArray["Active"] = active as AnyObject
        returnArray["MaxAllowed"] = maxAllowed as AnyObject
        returnArray["Required"] = required as AnyObject
        returnArray["Image"] = image as AnyObject
        returnArray["ItemizeOnReceipt"] = itemizeOnReceipt as AnyObject
        returnArray["AllowMultipleValues"] = allowMultipleValues as AnyObject
        returnArray["TemporaryAttribute"] = temporaryAttribute as AnyObject
        returnArray["SingleProduct"] = singleProduct as AnyObject
        returnArray["Pounds"] = pounds as AnyObject
        returnArray["Dollars"] = dollars as AnyObject
        returnArray["Months"] = months as AnyObject
        returnArray["Hours"] = hours as AnyObject
        returnArray["Other"] = other as AnyObject
        returnArray["Deleted"] = deleted as AnyObject
        var attributesArray: [AnyObject] = []
        attributes?.forEach {
            attributesArray.append($0.encode() as AnyObject )
        }
        returnArray["Attributes"] = attributesArray as AnyObject
        
        return returnArray
    }
    
}

//
//  Service+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON


extension Service: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> Service {
        let id = j["ID"].intValue
        let service = Service(id: id)
        
        service.name = j["Name"].stringValue
        service.description = j["Description"].stringValue
        service.active = j["Active"].boolValue
        service.taxable = j["Taxable"].boolValue
        service.isBeta = j["IsBeta"].bool
        service.rate = j["Rate"].double
        service.price = j["Price"].doubleValue
        service.priceBasedOn = j["PriceBasedOn"].stringValue
        service.isSelected = j["IsSelected"].boolValue
        
        service.inactiveImage = j["InactiveImage"].stringValue
        service.activeImage = j["ActiveImage"].stringValue
        service.parentID = j["ParentID"].intValue

        let typesOfService = try j["TypesOfService"].arrayValue.flatMap { try Service.decode($0) }
        
        service.unitType = j["UnitType"].stringValue
        service.roundPriceNearest = j["RoundPriceNearest"].doubleValue
        service.roundPrice = j["RoundPrice"].boolValue
        service.typesOfService = typesOfService
        
        return service
    }
}

extension Service: Encodable {
    
    func encode() -> [String : AnyObject] {
        var returnArray: [String : AnyObject] = [:]
        
        returnArray["ID"] = id as AnyObject
        returnArray["Name"] = name as AnyObject
        returnArray["Description"] = description as AnyObject
        returnArray["Active"] = active as AnyObject
        returnArray["Taxable"] = taxable as AnyObject
        returnArray["IsBeta"] = isBeta as AnyObject
        returnArray["Rate"] = rate as AnyObject
        returnArray["Price"] = price as AnyObject
        returnArray["PriceBasedOn"] = priceBasedOn as AnyObject
        returnArray["IsSelected"] = isSelected as AnyObject
        returnArray["InactiveImage"] = inactiveImage as AnyObject
        returnArray["ActiveImage"] = activeImage as AnyObject
        returnArray["ParentID"] = parentID as AnyObject
        returnArray["UnitType"] = unitType as AnyObject
        returnArray["RoundPriceNearest"] = roundPriceNearest as AnyObject
        returnArray["RoundPrice"] = roundPrice as AnyObject
        
        var typesOfServiceArray: [AnyObject] = []
        typesOfService?.forEach {
            typesOfServiceArray.append($0.encode() as AnyObject ?? "" as AnyObject)
        }
        returnArray["TypesOfService"] = typesOfServiceArray as AnyObject
        
        return returnArray
    }
    
}

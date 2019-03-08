//
//  OrderGarment+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON


extension OrderGarment: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> OrderGarment {
        let id = j["ID"].intValue
        let garment = OrderGarment(id: id)
        
        garment.orderId = j["OrderId"].intValue
        let properties = try j["Properties"].arrayValue.flatMap { try Category.decode($0) }
        garment.properties = properties
        
        return garment
    }
}

extension OrderGarment: Encodable {
    
    func encode() -> [String : AnyObject] {
        var returnArray: [String : AnyObject] = [:]
        
        returnArray["OrderId"] = orderId as AnyObject
        
        var propertiesArray: [AnyObject] = []
        properties?.forEach {
            propertiesArray.append($0.encode() as AnyObject ?? "" as AnyObject)
        }
        returnArray["Properties"] = propertiesArray as AnyObject
        
        return returnArray
    }
    
}

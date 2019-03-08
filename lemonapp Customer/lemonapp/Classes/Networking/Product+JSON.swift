//
//  Product+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import SwiftyJSON

extension Product: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> Product {

        let id = j["ProductID"].int ?? 0
        let name = j["ProductName"].string ?? ""
        let description = j["ProductDescription"].string ?? ""
        let isActive = j["Active"].bool ?? false
        let price = j["Price"].float ?? 0.0
        let taxable = j["Taxable"].bool ?? false
        let useWeight = j["UseWeight"].bool ?? false
        let parentId = j["ParentID"].int ?? 0
 
        return Product(id: id,
            name: name,
            description: description,
            isActive: isActive,
            price: price,
            taxable: taxable,
            useWeight: useWeight,
            parentId: parentId)
    }
}

extension Product: Encodable {
    
    func encode() -> [String : AnyObject] {
        var returnArray: [String : AnyObject] = [:]
        
        returnArray["ProductName"] = name as AnyObject
        returnArray["ProductDescription"] = description as AnyObject
        returnArray["Active"] = isActive as AnyObject
        returnArray["Price"] = price as AnyObject
        returnArray["Taxable"] = taxable as AnyObject
        returnArray["UseWeight"] = useWeight as AnyObject
        returnArray["ParentID"] = parentId as AnyObject
        
        return returnArray
    }
    
}

//
//  GarmentType+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import SwiftyJSON

extension GarmentType: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> GarmentType {
        return GarmentType(id: try j["GarmentTypeId"].value(),
            type: j["GarmentType1"].string,
            description: j["Description"].string)
    }
}

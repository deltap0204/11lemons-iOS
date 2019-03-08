//
//  GarmentBrand+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import SwiftyJSON

extension GarmentBrand: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> GarmentBrand {
        return GarmentBrand(id: try j["BrandId"].value(),
            name: j["BrandName"].string,
            description: j["Description"].string)
    }
}


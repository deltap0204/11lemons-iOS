//
//  Garment+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import SwiftyJSON

extension Garment: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> Garment {
        return Garment(id: try j["GarmentID"].value(),
            userId:  try j["UserID"].value(),
            description:  j["Description"].string,
            imageName:  j["PhotoLink"].string,
            brand:  try GarmentBrand.decode(j["Brand1"]),
            type: try GarmentType.decode(j["GarmentType"]))
    }
}

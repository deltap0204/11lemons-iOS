//
//  LocationData+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import SwiftyJSON

extension LocationData: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> LocationData {
        return LocationData(
            zipId: try j["ZipId"].value(),
            zipCode: try j["ZipCode"].value(),
            city: try j["City"].value(),
            state: try j["State"].value(),
            lat: try j["LatY"].value(),
            long: try j["LongX"].value(),
            allowReg: try j["AllowReg"].value())
    }
}

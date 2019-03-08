//
//  OrderImages+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON


extension OrderImages: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> OrderImages {
        let id = j["ID"].intValue
        let detail = OrderImages(id: id)
        detail.orderID = j["OrderID"].intValue
        detail.imageURL = j["ImageURL"].stringValue
        return detail
    }
}

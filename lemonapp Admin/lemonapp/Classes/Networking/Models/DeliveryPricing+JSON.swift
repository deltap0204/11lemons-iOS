//
//  DeliveryPricing+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON


extension DeliveryPricing: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> DeliveryPricing {
        let type = DeliveryOption(rawValue: j["DeliverySurchargeID"].intValue)
        let price = j["Price"].doubleValue
        let pricing = DeliveryPricing(type: type ?? .afterTomorrow, amount: price)
        pricing.active = j["Active"].boolValue
        return pricing
    }

}

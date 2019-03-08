//
//  Delivery+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON


extension Delivery: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> Delivery {
        var delivery = Delivery()
        delivery.deliveryUpchargeAmount = j["DeliveryUpchargeAmount"].doubleValue
        delivery.deliveryDate = Date.fromServerString(j["DeliveryRequestDate"].string)
        delivery.deliveryRequestDate = delivery.deliveryDate
        delivery.estimatedArrivalDate = Date.fromServerString(j["EstimatedArrival"].string)
        delivery.estimatedPickupDate = Date.fromServerString(j["EstimatedPickup"].string)
        delivery.deliverySurchargeID = j["DeliverySurcharge"].intValue
        delivery.pickupAddress = try? Address.decode(j["PickUpAddress"])
        delivery.dropoffAddress = try? Address.decode(j["DropOffAddress"])
        return delivery
    }
}

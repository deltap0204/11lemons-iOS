//
//  Delivery.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


struct Delivery {
    var deliveryDate: Date?
    var deliveryUpchargeAmount: Double?
    
    var deliverySurchargeID: Int?
    
    var deliveryRequestDate: Date?
    var estimatedArrivalDate: Date?
    var estimatedPickupDate: Date?
    
    var pickupAddressId: Int?
    var pickupAddress: Address? {
        didSet {
            if let address = pickupAddress {
                pickupAddressId = address.id
            }
        }
    }
    
    var dropoffAddressId: Int?
    var dropoffAddress: Address? {
        didSet {
            if let address = dropoffAddress {
                dropoffAddressId = address.id
            }
        }
    }
    
    func isFree() -> Bool {
        return deliveryUpchargeAmount == 0.0
    }
}

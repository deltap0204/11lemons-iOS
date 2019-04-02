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
    
    init() {}
    
    init(entity: DeliveryEntity) {
        self.deliveryDate = entity.deliveryDate
        self.deliveryUpchargeAmount = entity.deliveryUpchargeAmount.value
        self.deliverySurchargeID = entity.deliverySurchargeID.value
        self.deliveryRequestDate = entity.deliveryRequestDate
        self.estimatedArrivalDate = entity.estimatedArrivalDate
        self.estimatedPickupDate = entity.estimatedPickupDate
        
        self.pickupAddressId = entity.pickupAddressId.value
        if let addressEntity = entity.pickupAddress {
            self.pickupAddress = Address(entity: addressEntity)
        } else {
            self.pickupAddress = nil
        }
        
        self.dropoffAddressId = entity.dropoffAddressId.value
        if let addressEntity = entity.dropoffAddress {
            self.dropoffAddress = Address(entity: addressEntity)
        } else {
            self.dropoffAddress = nil
        }
    }
}

//
//  DeliveryEntity.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//


import Foundation
import RealmSwift
public class DeliveryEntity: Object {
    @objc dynamic var deliveryDate: Date? = nil
    
    @objc dynamic var deliveryRequestDate: Date? = nil
    @objc dynamic var estimatedArrivalDate: Date? = nil
    @objc dynamic var estimatedPickupDate: Date? = nil
    let deliveryUpchargeAmount = RealmOptional<Double>()
    let deliverySurchargeID = RealmOptional<Int>()
    
    let pickupAddressId = RealmOptional<Int>()
    @objc dynamic var pickupAddress: AddressEntity? {
        didSet {
            if let address = pickupAddress {
                pickupAddressId.value = address.id.value
            }
        }
    }
    let dropoffAddressId = RealmOptional<Int>()
    @objc dynamic var dropoffAddress: AddressEntity? {
        didSet {
            if let address = dropoffAddress {
                dropoffAddressId.value = address.id.value
            }
        }
    }
    
    static func create(with delivery: Delivery) -> DeliveryEntity {
        let deliveryEntity = DeliveryEntity()
        
        deliveryEntity.deliveryDate = delivery.deliveryDate
        deliveryEntity.deliveryUpchargeAmount.value = delivery.deliveryUpchargeAmount
        deliveryEntity.deliverySurchargeID.value = delivery.deliverySurchargeID
        deliveryEntity.deliveryRequestDate = delivery.deliveryRequestDate
        deliveryEntity.estimatedArrivalDate = delivery.estimatedArrivalDate
        deliveryEntity.estimatedPickupDate = delivery.estimatedPickupDate
        deliveryEntity.pickupAddressId.value = delivery.pickupAddressId
        if let address = delivery.pickupAddress {
            deliveryEntity.pickupAddress = AddressEntity.create(with: address)
        } else {
            deliveryEntity.pickupAddress = nil
        }
        
        deliveryEntity.dropoffAddressId.value = delivery.dropoffAddressId
        if let address = delivery.dropoffAddress {
            deliveryEntity.dropoffAddress = AddressEntity.create(with: address)
        } else {
            deliveryEntity.dropoffAddress = nil
        }
        
        return deliveryEntity
    }
}


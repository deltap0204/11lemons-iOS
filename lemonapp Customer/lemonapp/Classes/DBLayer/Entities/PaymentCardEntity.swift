//
//  PaymentCardEntity.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//


import Foundation
import RealmSwift
public class PaymentCardEntity: Object, RealmOptionalType {
    @objc dynamic var type: String? = nil
    let id = RealmOptional<Int>()
    @objc dynamic var number = ""
    @objc dynamic var expiration = ""
    @objc dynamic var secCode = ""
    @objc dynamic var deleted = false
    @objc dynamic var userId = 0
    @objc dynamic var token: String? = nil
    @objc dynamic var billingAddress: BillingAddressEntity? = nil
    
    static func create(with paymentCard: PaymentCard) -> PaymentCardEntity {
        let paymentCardEntity = PaymentCardEntity()
        
        paymentCardEntity.type = paymentCard.type.rawValue
        paymentCardEntity.id.value = paymentCard.id
        paymentCardEntity.number = paymentCard.number
        paymentCardEntity.expiration = paymentCard.expiration
        paymentCardEntity.secCode = paymentCard.secCode
        paymentCardEntity.deleted = paymentCard.deleted
        paymentCardEntity.userId = paymentCard.userId
        paymentCardEntity.token = paymentCard.token
        if let address = paymentCard.billingAddress {
            paymentCardEntity.billingAddress = BillingAddressEntity.create(with: address)
        }else {
            paymentCardEntity.billingAddress = nil
        }
        
        
        return paymentCardEntity
    }
}


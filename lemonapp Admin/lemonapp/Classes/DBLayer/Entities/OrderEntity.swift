//
//  OrderEntity.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//

import Foundation
import RealmSwift

public class OrderEntity: Object {
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    @objc dynamic var id: Int = 0
    let userId = RealmOptional<Int>()
    let lastModifiedUserId = RealmOptional<Int>()
    @objc dynamic var orderPlaced: Date? = nil
    let repeatState = RealmOptional<Bool>()
    @objc dynamic var notes = ""
    @objc dynamic var orderAmount: OrderAmountEntity? = OrderAmountEntity()
    let orderDetails = List<OrderDetailEntity>()
    let orderImages = List<OrderImagesEntity>()
    @objc dynamic var lastModified: Date? = nil
    let feedbackRating = RealmOptional<Int>()
    @objc dynamic var feedbackText: String? = nil
    
    let paymentId = RealmOptional<Int>()
    @objc dynamic var card : PaymentCardEntity? {
        didSet {
            if let card = card {
                paymentId.value = card.id.value
            }
        }
    }
    @objc dynamic  var applePayToken: String? = nil
    
    @objc dynamic var privateDetergent = Detergent.Original.rawValue
    var detergent: Detergent {
        get { return Detergent(rawValue: privateDetergent)! }
        set { privateDetergent = newValue.rawValue }
    }
    
    @objc dynamic var privateShirt = Shirt.Hanger.rawValue
    var shirt: Shirt {
        get { return Shirt(rawValue: privateShirt)! }
        set { privateShirt = newValue.rawValue }
    }
    
    @objc dynamic var privateDryer = Dryer.Bounce.rawValue
    var dryer: Dryer {
        get { return Dryer(rawValue: privateDryer)! }
        set { privateDryer = newValue.rawValue }
    }
    
    @objc dynamic var privateSoftener = Softener.Downy.rawValue
    var softener: Softener {
        get { return Softener(rawValue: privateSoftener)! }
        set { privateSoftener = newValue.rawValue }
    }
    
    @objc dynamic var delivery: DeliveryEntity? = DeliveryEntity()
    @objc dynamic var privateStatus = OrderStatus.awaitingPickup.rawValue
    var status : OrderStatus {
        get { return OrderStatus(rawValue: privateStatus)! }
        set { privateStatus = newValue.rawValue }
    }
    
    let promoId = RealmOptional<Int>()
    @objc dynamic var tips = 0
    @objc dynamic var lastModifiedUser: UserEntity? = nil
    @objc dynamic var createdBy: UserEntity? = nil
    
    @objc dynamic var privatePaymentStatus = OrderPaymentStatus.paymentNotProcessed.rawValue
    var paymentStatus : OrderPaymentStatus {
        get { return OrderPaymentStatus(rawValue: privatePaymentStatus)! }
        set { privatePaymentStatus = newValue.rawValue }
    }
    
    @objc dynamic var privateStarch = Starch.None.rawValue
    var starch : Starch {
        get { return Starch(rawValue: privateStarch)! }
        set { privateStarch = newValue.rawValue }
    }
    
    var hasChanges: Bool = false
    
    static func create(with order: Order) -> OrderEntity {
        var orderEntity = OrderEntity()
        orderEntity.id = order.id
        orderEntity.userId.value = order.userId
        orderEntity.lastModifiedUserId.value = order.lastModifiedUserId
        orderEntity.orderPlaced = order.orderPlaced
        orderEntity.repeatState.value = order.repeatState
        orderEntity.notes = order.notes
        orderEntity.orderAmount = OrderAmountEntity.create(with: order.orderAmount)
        orderEntity.orderDetails.removeAll()
        let newOrderDetails = order.orderDetails?.compactMap({OrderDetailEntity.create(with: $0)}) ?? []
        orderEntity.orderDetails.append(objectsIn: newOrderDetails)
        
        orderEntity.orderImages.removeAll()
        let orderImgs = order.orderImages?.compactMap({ OrderImagesEntity.create(with: $0) }) ?? []
        orderEntity.orderImages.append(objectsIn: orderImgs)
        
        orderEntity.lastModified = order.lastModified
        orderEntity.feedbackRating.value = order.feedbackRating
        orderEntity.feedbackText = order.feedbackText
        orderEntity.paymentId.value = order.paymentId
        
        if let paymentCard = order.card {
            orderEntity.card = PaymentCardEntity.create(with: paymentCard)
        } else {
            orderEntity.card = nil
        }

        orderEntity.applePayToken = order.applePayToken
        orderEntity.detergent = order.detergent
        orderEntity.shirt = order.shirt
        orderEntity.dryer = order.dryer
        orderEntity.softener = order.softener
        
        orderEntity.delivery = DeliveryEntity.create(with: order.delivery)
        
        orderEntity.status = order.status
        
        orderEntity.promoId.value = order.promoId
        orderEntity.tips = order.tips
        if let user = order.lastModifiedUser {
            orderEntity.lastModifiedUser = UserEntity.create(with: user)
        } else {
            orderEntity.lastModifiedUser = nil
        }
        
        if let user = order.createdBy {
            orderEntity.createdBy = UserEntity.create(with: user)
        } else {
            orderEntity.createdBy = nil
        }
        
        orderEntity.paymentStatus = order.paymentStatus
        orderEntity.starch = order.starch
        orderEntity.hasChanges = order.hasChanges
        return orderEntity
    }
}

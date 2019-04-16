//
//  Order.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation

import Bond

final class Order {
    
    var id = 0
    var userId: Int?
    var lastModifiedUserId: Int?
    var orderPlaced: Date?
    var repeatState: Bool?
    var notes = ""
    var orderAmount = OrderAmount()
    var orderDetails: [OrderDetail]?
    var orderImages: [OrderImages]?
    var lastModified: Date?
    var feedbackRating: Int?
    var feedbackText: String?
    
    var paymentId: Int?
    var card: PaymentCard? {
        didSet {
            if let card = card {
                paymentId = card.id
            }
        }
    }
    var applePayToken: String?
    
    var serviceType: [ServiceType] = [ServiceType.WashFold, ServiceType.DryClean, ServiceType.LaunderPress]
    var detergent = Detergent.Original
    var shirt = Shirt.Hanger
    var delivery = Delivery()
    var status = OrderStatus.awaitingPickup
    let viewed = Observable(true)
    var promoId: Int?
    var dryer = Dryer.Bounce
    var softener = Softener.Downy
    var tips = 0
    var lastModifiedUser: User?
    var createdBy: User?
    var paymentStatus = OrderPaymentStatus.paymentNotProcessed
    var starch = Starch.None
    
    let updated = Observable(false)
    
    init() {}
    
    init(id: Int,
         orderAmount: OrderAmount,
         orderPlaced: Date?,
         repeatState: Bool?,
         notes: String?,
         feedbackRating: Int?,
         feedbackText: String?,
         delivery: Delivery,
         status: OrderStatus,
         paymentStatus: OrderPaymentStatus,
         orderDetails: [OrderDetail]?,
         orderImages: [OrderImages]?,
         paymentId: Int?,
         promoId: Int?,
         lastModified: Date?,
         detergent: Detergent,
         shirt: Shirt,
         services: [ServiceType],
         dryer: Dryer,
         softener: Softener,
         tips: Int,
         lastModifiedUser: User? = nil,
         createdBy: User? = nil) {
        
        self.id = id
        self.orderAmount = orderAmount
        self.orderPlaced = orderPlaced
        self.repeatState = repeatState
        self.delivery = delivery
        self.status = status
        self.paymentStatus = paymentStatus
        self.orderDetails = orderDetails
        self.orderImages = orderImages
        self.paymentId = paymentId
        self.promoId = promoId
        self.lastModified = lastModified
        self.detergent = detergent
        self.shirt = shirt
        self.serviceType = services
        self.dryer = dryer
        self.notes = notes ?? ""
        self.feedbackRating = feedbackRating ?? 0
        self.feedbackText = feedbackText ?? ""
        self.softener = softener
        self.tips = tips
        self.createdBy = createdBy
        self.lastModifiedUser = lastModifiedUser
    }
    
    init(entity: OrderEntity) {
        let newOrderAmount = entity.orderAmount == nil ? OrderAmount() : OrderAmount(entity:entity.orderAmount!)
        
        self.id = entity.id
        self.orderAmount = newOrderAmount
        self.orderPlaced = entity.orderPlaced
        self.repeatState = entity.repeatState.value
        if let deliveryEntity = entity.delivery {
            self.delivery = Delivery(entity:deliveryEntity)
        }
        self.status = entity.status
        self.paymentStatus = entity.paymentStatus
        self.orderDetails = entity.orderDetails.compactMap { OrderDetail(entity: $0) }
        self.orderImages = entity.orderImages.compactMap { OrderImages(entity: $0) }
        self.paymentId = entity.paymentId.value
        self.promoId = entity.promoId.value
        self.lastModified = entity.lastModified
        self.detergent = entity.detergent
        self.shirt = entity.shirt
        self.serviceType = [ServiceType.WashFold, ServiceType.DryClean, ServiceType.LaunderPress]
        self.dryer = entity.dryer
        self.notes = entity.notes
        self.feedbackRating = entity.feedbackRating.value
        self.feedbackText = entity.feedbackText
        self.softener = entity.softener
        self.tips = entity.tips
        
        if let user = entity.createdBy {
            self.createdBy = User(entity: user)
        } else {
            self.createdBy = nil
        }
        
        if let user = entity.lastModifiedUser {
            self.lastModifiedUser = User(entity: user)
        } else {
            self.lastModifiedUser = nil
        }
        
        self.userId = entity.userId.value
        self.lastModifiedUserId = entity.lastModifiedUserId.value
        if let c = entity.card {
            self.card = PaymentCard(entity: c)
        } else {
            self.card = nil
        }
        
        self.applePayToken = entity.applePayToken
        self.starch = entity.starch
    }
    
    
    //lucas review this
    var hasChanges: Bool {
        return true
    }
    
    func reset() {
        self.shirt = .Hanger
        self.softener = .Downy
        self.dryer = .Bounce
        self.tips = 0
        self.detergent = .Original
        self.serviceType = [ServiceType.WashFold, ServiceType.DryClean, ServiceType.LaunderPress]
        self.notes = ""
    }
}

extension Order: DashboardItem {
    
    var repeated: Bool {
        return repeatState == true
    }
    
    var compareDate: Date? {
        return self.lastModified
    }
    
    var dashboardItemType: DashboardItemType {
        return .order
    }
}

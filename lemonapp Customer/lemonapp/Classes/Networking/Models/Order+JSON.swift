//
//  Order+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Order: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> Order {
        let orderAmount = try OrderAmount.decode(j)
        let orderPlaced = Date.fromServerString(j["OrderPlaced"].string)
        let repeatState = j["Repeat"].boolValue
        let notes = j["Notes"].stringValue
        let feedbackRating = j["FeedbackRating"].intValue
        let feedbackText = j["FeedbackText"].stringValue
        let delivery = try Delivery.decode(j)
        let status = OrderStatus(rawValue: j["OrderStatus"].intValue) ?? .awaitingPickup
        let paymentStatus = OrderPaymentStatus(rawValue: j["PaymentStatus"].intValue) ?? .paymentNotProcessed
        let orderDetails = try j["OrderDetails"].arrayValue.compactMap { try OrderDetail.decode($0) }
        let orderImages = try j["OrderImages"].arrayValue.compactMap { try OrderImages.decode($0) }
        let paymentId = j["PaymentID"].int
        let promoId = j["PromoID"].int
        let shirt = Shirt(rawValue: j["Shirts"].stringValue) ?? .Hanger
        let softener = Softener(rawValue: j["Order_Pref_FabricSoftener"].stringValue) ?? .None
        let dryer = Dryer(rawValue: j["Order_Pref_DryerSheet"].stringValue) ?? .None
        let tips = j["OrderTipPercentage"].int ?? 0
        let detergent = Detergent(rawValue: j["Detergent"].stringValue) ?? .Original
        let services = j["ServiceType"].stringValue.components(separatedBy: ",").compactMap { ServiceType(rawValue: $0) }
        let lastModified = Date.fromServerString(try? j["LastModified"].value())
        let payToken = j["Payments"]["CardToken"].stringValue
        let isAplepay = j["Payments"]["CardType"].string?.lowercased() == "applepay"
        
        let card: PaymentCard? = (try? PaymentCard.decode(j["Payments"]) ) ?? nil
        
        let lastModifiedUser = try? User.decode(j["LastModifiedUser"])
        let user = try? User.decode(j["Users"])
        
        let order = Order(id: try j["OrderID"].value(),
            orderAmount: orderAmount,
            orderPlaced: orderPlaced,
            repeatState: repeatState,
            notes: notes,
            feedbackRating: feedbackRating,
            feedbackText: feedbackText,
            delivery: delivery,
            status: status,
            paymentStatus: paymentStatus,
            orderDetails: orderDetails,
            orderImages: orderImages,
            paymentId: paymentId,
            promoId: promoId,
            lastModified: lastModified,
            detergent: detergent,
            shirt: shirt,
            services: services,
            dryer: dryer,
            softener: softener,
            tips: tips,
            card: card,
            lastModifiedUser: lastModifiedUser,
            createdBy: user
        )
        order.applePayToken = isAplepay ? payToken : ""
        order.promoId = promoId
        return order
    }
}


extension Order: Encodable {
    
    func encode() -> [String : AnyObject] {
        var paymentId = 0
        var cardType = "applepay"
        var token = applePayToken ?? ""
        if let card = card {
            paymentId = card.id ?? 0
            cardType = card.type.rawValue
            token = card.token ?? ""
        }
        let serviceTypeList = (serviceType.map { $0.rawValue } as NSArray).componentsJoined(by: ",")
        
        var returnArray: [String : AnyObject] = [:]
        
        var auxDelivery: Delivery = delivery
        var address = auxDelivery.pickupAddress
        
        returnArray["OrderPlaced"] = orderPlaced?.serverString() as AnyObject ?? "" as AnyObject
        returnArray["UserID"] = userId as AnyObject ?? 0 as AnyObject
        returnArray["PickUpAddress"] = auxDelivery.pickupAddress?.encode() as AnyObject ?? "" as AnyObject
        
        returnArray["DropOffAddress"] = delivery.dropoffAddress?.encode() as AnyObject ?? "" as AnyObject
        
        returnArray["PickUpAddressID"] = delivery.pickupAddress?.id as AnyObject ?? 0 as AnyObject
        returnArray["DropOffAddressID"] = delivery.dropoffAddress?.id as AnyObject ?? 0 as AnyObject
        returnArray["Repeat"] = "NO" as AnyObject
        returnArray["Notes"] = notes as AnyObject
        returnArray["FeedbackRating"] = feedbackRating as AnyObject
        returnArray["FeedbackText"] = feedbackText as AnyObject
        returnArray["EstimatedPickup"] = delivery.estimatedPickupDate?.serverString() as AnyObject ?? "" as AnyObject
        returnArray["EstimatedArrival"] = delivery.estimatedArrivalDate?.serverString() as AnyObject ?? "" as AnyObject
        returnArray["DeliveryRequestDate"] = delivery.deliveryDate?.serverString() as AnyObject ?? "" as AnyObject
        returnArray["ServiceType"] = serviceTypeList as AnyObject
        returnArray["Detergent"] = detergent.rawValue as AnyObject
        returnArray["Shirts"] = shirt.rawValue as AnyObject
        returnArray["DeliveryUpchargeAmount"] = delivery.deliveryUpchargeAmount as AnyObject ?? 0.0 as AnyObject
        returnArray["DeliverySurcharge"] = delivery.deliverySurchargeID as AnyObject ?? 0 as AnyObject
        returnArray["OrderStatus"] = status.rawValue as AnyObject
        returnArray["PaymentStatus"] = paymentStatus.rawValue as AnyObject
        returnArray["Amount"] = 0.1 as AnyObject
        if (card != nil || !token.isEmpty) {
            returnArray["PaymentID"] = paymentId as AnyObject
            returnArray["Payments"] = ["PaymentID": paymentId as AnyObject, "CardType": cardType as AnyObject,  "CardToken": token as AnyObject] as AnyObject
        }
        returnArray["PromoID"] = promoId as AnyObject ?? 0 as AnyObject
        returnArray["Order_Pref_FabricSoftener"] = softener.rawValue as AnyObject
        returnArray["Order_Pref_DryerSheet"] = dryer.rawValue as AnyObject
        returnArray["OrderTipPercentage"] = tips as AnyObject
        
        return returnArray
    }
    
}

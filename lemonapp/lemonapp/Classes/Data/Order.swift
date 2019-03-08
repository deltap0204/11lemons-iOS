//
//  Order.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation
import CoreData
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
    
    fileprivate var _dataModel: OrderModel
    init() {
        _dataModel = OrderModel()
    }
    
    
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
         dataModel: OrderModel? = nil,
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
        let oldDataModel = dataModel ?? LemonCoreDataManager.findWithId(id)
        self._dataModel = oldDataModel ?? OrderModel()
        if let oldDataModel = oldDataModel {
            self.viewed.value = (oldDataModel.viewed && status == OrderStatus(rawValue: oldDataModel.status.intValue)) || status == .archived || status == .canceled
        }
        self.viewed.skip(first: 1).observeNext { [weak self] _ in
            self?.syncDataModel()
        }
        
    }
    
    convenience init(orderModel: OrderModel) {
        let orderAmount = OrderAmount(
            amount: orderModel.amount.doubleValue,
            tax: orderModel.amountTax.doubleValue,
            amountWithoutTax: orderModel.amountWithoutTax.doubleValue,
            numberOfItems: orderModel.numberOfItems.intValue,
            state: orderModel.amountState
        )
        var delivery = Delivery()
        delivery.deliveryDate = orderModel.deliveryDate
        delivery.deliveryUpchargeAmount = orderModel.deliveryUpchargeAmount?.doubleValue
        delivery.estimatedArrivalDate = orderModel.deliveryEstimatedArrivalDate
        delivery.estimatedPickupDate = orderModel.deliveryEstimatedPickupDate
//        var pickUpAddress: Address? = nil
        if let pickUpAddressModel = orderModel.pickUpAddress {
            delivery.pickupAddress = Address(addressModel: pickUpAddressModel)
        }
//        var dropOffAddress: Address? = nil
        if let dropOffAddressModel = orderModel.dropOffAddress {
            delivery.dropoffAddress = Address(addressModel: dropOffAddressModel)
        }
        
        let shirt = Shirt(rawValue: orderModel.shirt) ?? .Hanger
        let softener = Softener(rawValue: orderModel.softener) ?? .None
        let dryer = Dryer(rawValue: orderModel.dryer) ?? .None
        let tips = orderModel.tips.intValue
        let detergent = Detergent(rawValue: orderModel.detergent) ?? .Original
        let services = orderModel.serviceType.components(separatedBy: ",").flatMap { ServiceType(rawValue: $0) }
        let feedbackRating = orderModel.feedbackRating.intValue
        
        var lmUser: User? = nil
        if let lastModifiedUser = orderModel.lastModifiedUser {
            lmUser = User(userModel: lastModifiedUser)
        }
        var user: User? = nil
        if let createdBy = orderModel.createdBy {
            user = User(userModel: createdBy)
        }
        
        self.init(id: orderModel.id.intValue,
                  orderAmount: orderAmount,
                  orderPlaced: orderModel.placed as! Date,
                  repeatState: orderModel.repeatState,
                  notes: orderModel.notes,
                  feedbackRating: feedbackRating,
                  feedbackText: orderModel.feedbackText,
                  delivery: delivery,
                  status: OrderStatus(rawValue: orderModel.status.intValue) ?? .awaitingPickup,
                  paymentStatus: OrderPaymentStatus(rawValue: orderModel.paymentStatus.intValue) ?? .paymentNotProcessed,
                  orderDetails: orderModel.details.map { OrderDetail(orderDetailModel: $0) },
                  orderImages: orderModel.orderImages.map { OrderImages(orderImagesModel: $0) },
                  paymentId: orderModel.paymentId?.intValue,
                  promoId: nil,
                  lastModified: orderModel.lastModified,
                  detergent: detergent,
                  shirt: shirt,
                  services: services,
                  dryer: dryer,
                  softener: softener,
                  tips: tips,
                  dataModel: orderModel,
                  lastModifiedUser: lmUser,
                  createdBy: user)
        self.userId = orderModel.userId?.intValue
    }
    
    var hasChanges: Bool {
        let shirt = Shirt(rawValue: _dataModel.shirt) ?? .Hanger
        let softener = Softener(rawValue: _dataModel.softener) ?? .None
        let dryer = Dryer(rawValue: _dataModel.dryer) ?? .None
        let tips = _dataModel.tips.intValue
        let detergent = Detergent(rawValue: _dataModel.detergent) ?? .Original
        
        var hasChanges: Bool = false
        hasChanges = hasChanges || self.shirt != shirt
        hasChanges = hasChanges || self.softener != softener
        hasChanges = hasChanges || self.dryer != dryer
        hasChanges = hasChanges || self.tips != tips
        hasChanges = hasChanges || self.detergent != detergent
        hasChanges = hasChanges || self.notes != _dataModel.notes
        
        let services = _dataModel.serviceType.components(separatedBy: ",").flatMap { ServiceType(rawValue: $0) }
        if services.count != self.serviceType.count {
            hasChanges = true
        } else {
            for service in services {
                hasChanges = hasChanges || !serviceType.contains(service)
            }
        }
        
        return hasChanges
    }
    
    func sync(_ order: Order) {
        self.userId = order.userId
        self.orderPlaced = order.orderPlaced
        self.notes = order.notes
        self.feedbackRating = order.feedbackRating
        self.feedbackText = order.feedbackText
        self.repeatState = order.repeatState
        self.orderAmount = order.orderAmount
        self.paymentId = order.paymentId
        let viewed = self.viewed.value && status == order.status || status == .archived || status == .canceled
        self.status = order.status
        self.paymentStatus = order.paymentStatus
        self.delivery = order.delivery
        self.lastModified = order.lastModified
        self.shirt = order.shirt
        self.dryer = order.dryer
        self.softener = order.softener
        self.tips = order.tips
        self.serviceType = order.serviceType
        self.detergent = order.detergent
        self.lastModifiedUser = order.lastModifiedUser
        self.createdBy = order.createdBy
        LemonCoreDataManager.context.perform { [weak order, weak self] in
            if let strongSelf = self {
                let details = strongSelf._dataModel.details.map { $0 }
                strongSelf._dataModel.details.removeAll()
                LemonCoreDataManager.delete(false, objects: details)
                if let newOrderDetails = order?.orderDetails?.map({ $0.dataModel }) {
                    LemonCoreDataManager.insert(false, objects: newOrderDetails)
                }
                strongSelf.orderDetails = order?.orderDetails
                DispatchQueue.main.async {
                    strongSelf.viewed.value = viewed
                }
            }
        }
    }
    
    func reset() {
        
        let shirt = Shirt(rawValue: _dataModel.shirt) ?? .Hanger
        let softener = Softener(rawValue: _dataModel.softener) ?? .None
        let dryer = Dryer(rawValue: _dataModel.dryer) ?? .None
        let tips = _dataModel.tips.intValue
        let detergent = Detergent(rawValue: _dataModel.detergent) ?? .Original
        let services = _dataModel.serviceType.components(separatedBy: ",").flatMap { ServiceType(rawValue: $0) }
        
        self.shirt = shirt
        self.softener = softener
        self.dryer = dryer
        self.tips = tips
        self.detergent = detergent
        self.serviceType = services
        self.notes = _dataModel.notes
    }
}

extension Order: DataModelWrapper {
    
    var dataModel: NSManagedObject {
        return _dataModel
    }
    
    func syncDataModel() {
        _dataModel.id = NSNumber(value: id as Int)
        //_dataModel.userId = userId == nil ? userId : NSNumber(value: userId! as Int)
        if let userId = userId {
            _dataModel.userId = NSNumber(value: userId as Int)
        }
        _dataModel.placed = orderPlaced
        _dataModel.notes = notes
        _dataModel.feedbackRating = NSNumber(value: feedbackRating ?? 0 as Int)
        _dataModel.feedbackText = feedbackText ?? ""
        _dataModel.repeatState = repeatState ?? false
        _dataModel.amount = NSNumber(value: orderAmount.amount)
        _dataModel.amountWithoutTax = NSNumber(value: orderAmount.amountWithoutTax as Double)
        _dataModel.numberOfItems = NSNumber(value: orderAmount.numberOfItems as Int)
        _dataModel.amountTax = NSNumber(value: orderAmount.tax as Double)
        _dataModel.amountState = orderAmount.state
        //_dataModel.paymentId = paymentId == nil ? paymentId : NSNumber(value: self.paymentId! as Int)
        if let paymentId = paymentId {
            _dataModel.paymentId = NSNumber(value: paymentId as Int)
        }
        _dataModel.status = NSNumber(value: status.rawValue as Int)
        _dataModel.paymentStatus = NSNumber(value: paymentStatus.rawValue as Int)
        _dataModel.deliveryDate = delivery.deliveryDate
        _dataModel.deliveryUpchargeAmount = delivery.deliveryUpchargeAmount == nil ? nil : NSNumber(value: delivery.deliveryUpchargeAmount! as Double)
        _dataModel.deliveryEstimatedArrivalDate = delivery.estimatedArrivalDate
        _dataModel.deliveryEstimatedPickupDate = delivery.estimatedPickupDate
        _dataModel.lastModified = lastModified
        _dataModel.shirt = shirt.rawValue
        _dataModel.softener = softener.rawValue
        _dataModel.dryer = dryer.rawValue
        _dataModel.tips = NSNumber(value: tips)
        _dataModel.serviceType = serviceType.reduce("") { $0 + $1.rawValue + "," }
        _dataModel.detergent = detergent.rawValue
        _dataModel.viewed = viewed.value != nil ? viewed.value : false
        orderDetails?.forEach {
            if let orderDetailsModel = $0.dataModel as? OrderDetailsModel, !_dataModel.details.contains(orderDetailsModel) {
                if let exist = try? LemonCoreDataManager.fetch(OrderDetailsModel.self).contains(orderDetailsModel) {
                    if !exist {
                        LemonCoreDataManager.insert(false, objects: orderDetailsModel)
                    }
                }
                _dataModel.details.insert(orderDetailsModel)
            }
        }
        
        if let lastModifiedUser = lastModifiedUser {
            if let userModel = lastModifiedUser.dataModel as? UserModel {
                if let exist = try? LemonCoreDataManager.fetch(UserModel.self).contains(userModel) {
                    if !exist {
                        LemonCoreDataManager.insert(false, objects: userModel)
                    }
                }
            }
            _dataModel.createdBy = lastModifiedUser.dataModel as? UserModel
        }
        if let createdBy = createdBy {
            if let userModel = createdBy.dataModel as? UserModel {
                if let exist = try? LemonCoreDataManager.fetch(UserModel.self).contains(userModel) {
                    if !exist {
                        LemonCoreDataManager.insert(false, objects: userModel)
                    }
                }
            }
            _dataModel.createdBy = createdBy.dataModel as? UserModel
        }
        
        if let pickUpAddress = delivery.pickupAddress {
            if let addressModel = pickUpAddress.dataModel as? AddressModel {
                if let exist = try? LemonCoreDataManager.fetch(AddressModel.self).contains(addressModel) {
                    if !exist {
                        LemonCoreDataManager.insert(false, objects: addressModel)
                    }
                }
            }
            _dataModel.pickUpAddress = pickUpAddress.dataModel as? AddressModel
        }
        if let dropOffAddress = delivery.dropoffAddress {
            if let addressModel = dropOffAddress.dataModel as? AddressModel {
                if let exist = try? LemonCoreDataManager.fetch(AddressModel.self).contains(addressModel) {
                    if !exist {
                        LemonCoreDataManager.insert(false, objects: addressModel)
                    }
                }
            }
            _dataModel.dropOffAddress = dropOffAddress.dataModel as? AddressModel
        }
        
        saveDataModelChanges()
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

//
//  PFARecord.swift
//  EMBreakDepedencyRealm
//
//  Created by Ennio Masi on 10/07/2017.
//  Copyright © 2017 ennioma. All rights reserved.
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

    var delivery = DeliveryEntity()
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
        
        var delivery = DeliveryEntity.create(with: order.delivery)
        
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


public class UserEntity: Object, RealmOptionalType {
    override public static func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var id = 0
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var email = ""
    @objc dynamic var mobilePhone = ""
    @objc dynamic var profilePhoto: String? = nil
    @objc dynamic var preferences: PreferencesEntity? = PreferencesEntity()
    @objc dynamic var settings: SettingsEntity? = SettingsEntity()
    let defaultAddressId = RealmOptional<Int>()
    let walletAmount = RealmOptional<Double>()
    var referralCode: String? = nil
    @objc dynamic var isAdmin: Bool = false
    
    let defaultPaymentCardId = RealmOptional<Int>()
    
    static func create(with user: User) -> UserEntity {
        let userEntity = UserEntity()
        userEntity.id = user.id
        userEntity.firstName = user.firstName
        userEntity.lastName = user.lastName
        userEntity.email = user.email
        userEntity.mobilePhone = user.mobilePhone
        userEntity.profilePhoto = user.profilePhoto
        userEntity.preferences = PreferencesEntity.create(with: user.preferences)
        userEntity.settings = SettingsEntity.create(with: user.settings)
        userEntity.defaultAddressId.value = user.defaultAddressId
        userEntity.walletAmount.value = user.walletAmount
        userEntity.referralCode = user.referralCode
        userEntity.isAdmin = user.isAdmin
        userEntity.defaultPaymentCardId.value = user.defaultPaymentCardId
        return userEntity
    }
}

public class PreferencesEntity: Object {
    @objc dynamic var privateDetergent = Detergent.Original.rawValue
    var detergent: Detergent {
        get { return Detergent(rawValue: privateDetergent)! }
        set { privateDetergent = newValue.rawValue }
    }
    
    @objc dynamic var privateShirts = Shirt.Hanger.rawValue
    var Shirts: Shirt {
        get { return Shirt(rawValue: privateShirts)! }
        set { privateShirts = newValue.rawValue }
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

    @objc dynamic var tips = 0
    @objc dynamic var notes = ""
    @objc dynamic var scheduledWeekday = ""
    @objc dynamic var scheduledFrequency = 0
    
    
    static func create(with preferences: Preferences) -> PreferencesEntity {
        let preferencesEntity = PreferencesEntity()
        
        preferencesEntity.detergent = preferences.detergent
        preferencesEntity.Shirts = preferences.shirts
        preferencesEntity.dryer = preferences.dryer
        preferencesEntity.softener = preferences.softener
        preferencesEntity.tips = preferences.tips
        preferencesEntity.notes = preferences.notes
        preferencesEntity.scheduledWeekday = preferences.scheduledWeekday
        preferencesEntity.scheduledFrequency = preferences.scheduledFrequency

        return preferencesEntity
    }
}

public class SettingsEntity: Object {
    @objc dynamic var cloudClosetEnabled = false
    @objc dynamic var pushEnabled = false
    @objc dynamic var mailEnabled = false
    @objc dynamic var messageEnabled = false
    
    static func create(with settings: Settings) -> SettingsEntity {
        let settingsEntity = SettingsEntity()
        
        settingsEntity.cloudClosetEnabled = settings.cloudClosetEnabled
        settingsEntity.pushEnabled = settings.pushEnabled
        settingsEntity.mailEnabled = settings.mailEnabled
        settingsEntity.messageEnabled = settings.messageEnabled
        
        return settingsEntity
    }
}
public class OrderImagesEntity: Object {
    override public static func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var id = 0
    @objc dynamic var orderID = 0
    @objc dynamic var imageURL = ""
    
    static func create(with orderImages: OrderImages) -> OrderImagesEntity {
        let orderImagesEntity = OrderImagesEntity()
        orderImagesEntity.id = orderImages.id
        orderImagesEntity.orderID = orderImages.orderID
        orderImagesEntity.imageURL = orderImages.imageURL
        return orderImagesEntity
    }
}

public class OrderDetailEntity: Object {
    @objc dynamic var jsonOrder :OrderDetailsReceiptEntity? = nil
    override public static func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var id = 0
    @objc dynamic var orderId: Int = 0
    let quantity = RealmOptional<Int>()
    let pricePer = RealmOptional<Double>()
    let priceWithoutTaxes = RealmOptional<Double>()
    let tax = RealmOptional<Double>()
    let total = RealmOptional<Double>()
    let subtotal = RealmOptional<Double>()
    let weight = RealmOptional<Double>()
    @objc dynamic var service: ServiceEntity? = nil
    @objc dynamic var garment: OrderGarmentEntity? = nil
    @objc dynamic var product: ProductEntity? = nil
    
    static func create(with orderDetail: OrderDetail) -> OrderDetailEntity {
        var orderDetailEntity = OrderDetailEntity()
        orderDetailEntity.id = orderDetail.id
        orderDetailEntity.orderId =  orderDetail.orderId
        orderDetailEntity.quantity.value =  orderDetail.quantity
        orderDetailEntity.pricePer.value =  orderDetail.pricePer
        orderDetailEntity.priceWithoutTaxes.value =  orderDetail.priceWithoutTaxes
        orderDetailEntity.tax.value =  orderDetail.tax
        orderDetailEntity.total.value = orderDetail.total
        orderDetailEntity.subtotal.value = orderDetail.subtotal
        orderDetailEntity.weight.value = orderDetail.weight
        if let service = orderDetail.service {
            orderDetailEntity.service = ServiceEntity.create(with: service)
        } else {
            orderDetailEntity.service = nil
        }
        
        if let garment = orderDetail.garment {
            orderDetailEntity.garment = OrderGarmentEntity.create(with: garment)
        } else {
            orderDetailEntity.garment = nil
        }
        
        
        if let product = orderDetail.product {
            orderDetailEntity.product = ProductEntity.create(with: product)
        } else {
            orderDetailEntity.product = nil
        }
        return orderDetailEntity
    }
}

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

public class OrderAmountEntity: Object {
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var tax: Double = 0.0
    @objc dynamic var amountWithoutTax: Double = 0.0
    @objc dynamic var numberOfItems = 0
    @objc dynamic var state = ""
    
    static func create(with orderAmount: OrderAmount) -> OrderAmountEntity {
        let orderAmountEntity = OrderAmountEntity()
        orderAmountEntity.amount = orderAmount.amount
        orderAmountEntity.tax = orderAmount.tax
        orderAmountEntity.amountWithoutTax = orderAmount.amountWithoutTax
        orderAmountEntity.numberOfItems = orderAmount.numberOfItems
        orderAmountEntity.state = orderAmount.state

        return orderAmountEntity
    }
}

public class DeliveryEntity: Object {
    @objc dynamic var deliveryDate: Date? = nil
    let deliveryUpchargeAmount = RealmOptional<Double>()
    let deliverySurchargeID = RealmOptional<Int>()
    @objc dynamic var deliveryRequestDate: Date? = nil
    @objc dynamic var estimatedArrivalDate: Date? = nil
    @objc dynamic var estimatedPickupDate: Date? = nil
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

public class AddressEntity: Object, RealmOptionalType {
    let id = RealmOptional<Int>()
    @objc dynamic var street = ""
    @objc dynamic var aptSuite = ""
    @objc dynamic var city = ""
    @objc dynamic var state = ""
    @objc dynamic var zip = ""
    @objc dynamic var nickname = ""
    @objc dynamic var deleted = false
    @objc dynamic var userId = 0
    var notes: String? = nil
    
    static func create(with address: Address) -> AddressEntity {
        let addressEntity = AddressEntity()
        
        addressEntity.id.value = address.id
        addressEntity.street = address.street
        addressEntity.aptSuite = address.aptSuite
        addressEntity.city = address.city
        addressEntity.state = address.state
        addressEntity.zip = address.zip
        addressEntity.nickname = address.nickname
        addressEntity.deleted = address.deleted
        addressEntity.userId = address.userId
        addressEntity.notes = address.notes
        
        return addressEntity
    }
}

public class BillingAddressEntity: Object, RealmOptionalType {
    @objc dynamic var address: String = ""
    @objc dynamic var city: String = ""
    @objc dynamic var state: String = ""
    @objc dynamic var zip: String = ""
    
    static func create(with billingAddress: BillingAddress) -> BillingAddressEntity {
        let billingAddressEntity = BillingAddressEntity()
        billingAddressEntity.address = billingAddress.address
        billingAddressEntity.city = billingAddress.city
        billingAddressEntity.state = billingAddress.state
        billingAddressEntity.zip = billingAddress.zip
        return billingAddressEntity
    }
}

public class OrderDetailsReceiptEntity: Object, RealmOptionalType {
    override public static func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var id = 0
    @objc dynamic var orderId: Int = 0
    let quantity = RealmOptional<Int>()
    let pricePer = RealmOptional<Double>()
    let priceWithoutTaxes = RealmOptional<Double>()
    let tax = RealmOptional<Double>()
    let total = RealmOptional<Double>()
    let subtotal = RealmOptional<Double>()
    let weight = RealmOptional<Double>()
    @objc dynamic var service: ServiceEntity? = nil
    @objc dynamic var garment: OrderGarmentEntity? = nil
    
    @objc dynamic var product: ProductEntity? = nil
}

public class ServiceEntity: Object, RealmOptionalType {
    override public static func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var descriptions = ""
    @objc dynamic var active = false
    @objc dynamic var taxable = false
    let isBeta = RealmOptional<Bool>()
    let rate = RealmOptional<Double>()
    @objc dynamic var price: Double = 0.0
    @objc dynamic var priceBasedOn = ""
    @objc dynamic var isSelected = false
    @objc dynamic var parentID = 0
    @objc dynamic var activeImage = ""
    @objc dynamic var inactiveImage = ""
    let typesOfService = List<ServiceEntity>()
    @objc dynamic var unitType = ""
    @objc dynamic var roundPriceNearest: Double = 0.0
    @objc dynamic var roundPrice = false
    
    static func create(with service: Service) -> ServiceEntity {
        let serviceEntity = ServiceEntity()
        serviceEntity.id = service.id
        serviceEntity.name = service.name
        serviceEntity.descriptions = service.description
        serviceEntity.active = service.active
        serviceEntity.taxable = service.taxable
        serviceEntity.isBeta.value = service.isBeta
        serviceEntity.rate.value = service.rate
        serviceEntity.price = service.price
        serviceEntity.priceBasedOn = service.priceBasedOn
        serviceEntity.isSelected = service.isSelected
        serviceEntity.parentID = service.parentID
        serviceEntity.activeImage = service.activeImage
        serviceEntity.inactiveImage = service.inactiveImage
        serviceEntity.typesOfService.removeAll()
        let services = service.typesOfService?.compactMap { ServiceEntity.create(with: $0) } ?? []
        serviceEntity.typesOfService.append(objectsIn: services)
        serviceEntity.unitType = service.unitType
        serviceEntity.roundPriceNearest = service.roundPriceNearest
        serviceEntity.roundPrice = service.roundPrice
        return serviceEntity
    }
}

func == (lft: ServiceEntity, rgh: ServiceEntity) -> Bool {
    return lft.id == rgh.id
}

public class OrderGarmentEntity: Object, RealmOptionalType {
    override public static func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var id = 0
    @objc dynamic var orderId = 0
    let properties = List<CategoryEntity>()
    
    static func create(with orderGarment: OrderGarment) -> OrderGarmentEntity {
        let orderGarmentEntity = OrderGarmentEntity()
        orderGarmentEntity.id = orderGarment.id
        orderGarmentEntity.orderId = orderGarment.orderId
        orderGarmentEntity.properties.removeAll()
        let newProperties = orderGarment.properties?.compactMap { CategoryEntity.create(with: $0)} ?? []
        orderGarmentEntity.properties.append(objectsIn: newProperties)
        return orderGarmentEntity
    }
}

public class ProductEntity: Object, RealmOptionalType {
    override public static func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var descriptions = ""
    @objc dynamic var isActive = false
    @objc dynamic var price: Float = 0.0
    @objc dynamic var taxable = false
    @objc dynamic var useWeight = false
    @objc dynamic var parentId = 0
    let subproducts = List<ProductEntity>()
    
    static func create(with product: Product) -> ProductEntity {
        let productEntity = ProductEntity()
        productEntity.id = product.id
        productEntity.name = product.name
        productEntity.descriptions = product.description
        productEntity.isActive = product.isActive
        productEntity.price = product.price
        productEntity.taxable = product.taxable
        productEntity.useWeight = product.useWeight
        productEntity.parentId = product.parentId
        productEntity.subproducts.removeAll()
        let subProducts = product.subproducts.compactMap( {ProductEntity.create(with: $0)}) ?? []
        productEntity.subproducts.append(objectsIn: subProducts)
        return productEntity
    }
}

public class CategoryEntity: Object, RealmOptionalType {
    @objc dynamic var id = 0
    @objc dynamic var name: String = ""
    @objc dynamic var descriptions: String = ""
    @objc dynamic var active: Bool = false
    let maxAllowed = RealmOptional<Int>()
    let required = RealmOptional<Bool>()
    @objc dynamic var image: String = ""
    let itemizeOnReceipt = RealmOptional<Bool>()
    let allowMultipleValues = RealmOptional<Bool>()
    let temporaryAttribute = RealmOptional<Bool>()
    @objc dynamic var singleProduct: Bool = false
    @objc dynamic var pounds: Bool = false
    @objc dynamic var dollars: Bool = false
    @objc dynamic var months: Bool = false
    @objc dynamic var hours: Bool = false
    @objc dynamic var other: Bool = false
    @objc dynamic var deleted: Bool = false
    let attributes = List<AttributeEntity>()
    
    static func create(with category: Category) -> CategoryEntity {
        let categoryEntity = CategoryEntity()
        categoryEntity.id = category.id
        categoryEntity.name = category.name
        categoryEntity.descriptions = category.description
        categoryEntity.active = category.active
        categoryEntity.maxAllowed.value = category.maxAllowed
        categoryEntity.required.value = category.required
        categoryEntity.image = category.image
        categoryEntity.itemizeOnReceipt.value = category.itemizeOnReceipt
        categoryEntity.allowMultipleValues.value = category.allowMultipleValues
        categoryEntity.temporaryAttribute.value = category.temporaryAttribute
        categoryEntity.singleProduct = category.singleProduct
        categoryEntity.pounds = category.pounds
        categoryEntity.dollars = category.dollars
        categoryEntity.months = category.months
        categoryEntity.hours = category.hours
        categoryEntity.other = category.other
        categoryEntity.deleted = category.deleted
        categoryEntity.attributes.removeAll()
        let attributes = (category.attributes?.compactMap { AttributeEntity.create(with: $0) }) ?? []
        categoryEntity.attributes.append(objectsIn: attributes)
        return categoryEntity
    }
}

public class AttributeEntity: Object, RealmOptionalType {
    @objc dynamic var id = 0
    @objc dynamic var attributeName = ""
    @objc dynamic var categoryId = 0
    @objc dynamic var price: Double = 0.0
    @objc dynamic var oneTimeUse = false
    @objc dynamic var oneTimeUseProcessed = false
    @objc dynamic var descriptions = ""
    @objc dynamic var image = ""
    @objc dynamic var percentUpcharge = false
    @objc dynamic var roundPriceNearest = ""
    @objc dynamic var displayReceipt = false
    @objc dynamic var displayPriceList = false
    @objc dynamic var unitType = ""
    @objc dynamic var pieces = 0
    @objc dynamic var taxable = false
    @objc dynamic var upcharge = false
    @objc dynamic var dollarUpcharge = false
    @objc dynamic var itemizeOnReceipt = false
    @objc dynamic var roundPrice = false
    @objc dynamic var alwaysRoundUp = false
    @objc dynamic var upchargeAmount: Double = 0.0
    @objc dynamic var attributeCategory = ""
    @objc dynamic var isSelected = false
    @objc dynamic var upchargeMarkup: Double = 0.0
    @objc dynamic var inactiveImage = ""
    @objc dynamic var activeImage = ""
    @objc dynamic var deleted = false
    
    static func create(with attribute: Attribute) -> AttributeEntity {
        let attributeEntity = AttributeEntity()
        attributeEntity.id = attribute.id
        attributeEntity.attributeName = attribute.attributeName
        attributeEntity.categoryId = attribute.categoryId
        attributeEntity.price = attribute.price
        attributeEntity.oneTimeUse = attribute.oneTimeUse
        attributeEntity.oneTimeUseProcessed = attribute.oneTimeUseProcessed
        attributeEntity.descriptions = attribute.description
        attributeEntity.image = attribute.image
        attributeEntity.percentUpcharge = attribute.percentUpcharge
        attributeEntity.roundPriceNearest = attribute.roundPriceNearest
        attributeEntity.displayReceipt = attribute.displayReceipt
        attributeEntity.displayPriceList = attribute.displayPriceList
        attributeEntity.unitType = attribute.unitType
        attributeEntity.pieces = attribute.pieces
        attributeEntity.taxable = attribute.taxable
        attributeEntity.upcharge = attribute.upcharge
        attributeEntity.dollarUpcharge = attribute.dollarUpcharge
        attributeEntity.itemizeOnReceipt = attribute.itemizeOnReceipt
        attributeEntity.roundPrice = attribute.roundPrice
        attributeEntity.alwaysRoundUp = attribute.alwaysRoundUp
        attributeEntity.upchargeAmount = attribute.upchargeAmount
        attributeEntity.attributeCategory = attribute.attributeCategory
        attributeEntity.isSelected = attribute.isSelected
        attributeEntity.upchargeMarkup = attribute.upchargeMarkup
        attributeEntity.inactiveImage = attribute.inactiveImage
        attributeEntity.activeImage = attribute.activeImage
        attributeEntity.deleted = attribute.deleted
        return attributeEntity
    }
}




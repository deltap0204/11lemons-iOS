//
//  UserModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class UserModel: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var email: String
    @NSManaged var mobilePhone: String
    @NSManaged var profilePhoto: String?
    @NSManaged var addresses: Set<AddressModel>
    @NSManaged var orders: Set<OrderModel>
    @NSManaged var paymentCards: Set<PaymentCardModel>
    @NSManaged var defaultAddressId: NSNumber?
    @NSManaged var defaultPaymentCardId: NSNumber?
    @NSManaged var walletAmount: NSNumber?
    @NSManaged var referralCode: String?
    @NSManaged var isAdmin: Bool
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init(context: NSManagedObjectContext = LemonCoreDataManager.context,
                     id: Int,
                     firstName: String,
                     lastName: String,
                     email: String,
                     mobilePhone: String,
                     profilePhoto: String?,
                     defaultAddressId: Int?,
                     defaultPaymentCardId: Int?,
                     walletAmount: Double?,
                     referralCode: String?,
                     isAdmin: Bool) {
        
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: context)!
        self.init(entity: entity, insertInto: nil)
        self.id = NSNumber(value: id as Int)
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.mobilePhone = mobilePhone
        if let profilePhotoUrl = URL(string: profilePhoto?.removingPercentEncoding ?? "") {
            self.profilePhoto = profilePhotoUrl.lastPathComponent
        }
        if let defaultAddressId = defaultAddressId {
            self.defaultAddressId = defaultAddressId as NSNumber
        }
        if let defaultPaymentCardId = defaultPaymentCardId {
            self.defaultPaymentCardId = defaultPaymentCardId as NSNumber
        }
        if let walletAmount = walletAmount {
            self.walletAmount = walletAmount as NSNumber
        }
        
        self.referralCode = referralCode
        self.isAdmin = isAdmin
    }
}

extension UserModel: ModelNameProvider {
    class var modelName: String { return "User" }
}

extension UserModel {
    convenience init(context: NSManagedObjectContext = LemonCoreDataManager.context, user: User) {
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: context)!
        self.init(entity: entity, insertInto: nil)
        self.id = NSNumber(value: user.id as Int)
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.email = user.email
        self.mobilePhone = user.mobilePhone
        self.profilePhoto = URL(string: profilePhoto?.removingPercentEncoding ?? "")!.lastPathComponent
        self.defaultAddressId = defaultAddressId == nil ? defaultAddressId : NSNumber(value: user.defaultAddressId! as Int)
        self.defaultPaymentCardId = defaultPaymentCardId == nil ? defaultPaymentCardId : NSNumber(value: user.defaultPaymentCardId! as Int)
        self.walletAmount = walletAmount == nil ? walletAmount : NSNumber(value: user.walletAmount! as Double)
        self.referralCode = user.referralCode
        self.isAdmin = user.isAdmin
    }
}

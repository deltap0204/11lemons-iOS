//
//  User.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import SwiftyJSON
import Bond
import PassKit
import CoreData

final class User: Copying {
    
    fileprivate static let USER_ID_KEY              = "UserID"
    fileprivate static let USER_FIRST_NAME_KEY      = "First"
    fileprivate static let USER_LAST_NAME_KEY       = "Last"
    fileprivate static let USER_EMAIL_KEY           = "Email"
    fileprivate static let USER_MOBILE_KEY          = "Mobile"
    fileprivate static let USER_PHOTO_KEY           = "ProfilePic"
    fileprivate static let USER_ADDRESS_ID_KEY      = "DefaultAddress"
    fileprivate static let USER_PAYMENT_CARD_ID_KEY = "DefaultPayment"
    
    var id: Int
    var firstName: String
    var lastName: String
    var email: String
    var mobilePhone: String
    var profilePhoto: String?
    var preferences: Preferences
    var settings: Settings
    var defaultAddressId: Int?
    var walletAmount: Double?
    var referralCode: String?
    
    var defaultPaymentCardId: Int?    
    
    fileprivate var _dataModel: UserModel
    
    init(id: Int,
        firstName: String,
        lastName: String,
        email: String,
        mobilePhone: String,
        profilePhoto: String?,
        defaultAddressId: Int?,
        defaultPaymentCardId: Int?,
        settings: Settings,
        preferences: Preferences,
        walletAmount: Double?,
        referralCode: String?,
        dataModel: UserModel? = nil) {
            
            self.id = id
            self.firstName = firstName
            self.lastName = lastName
            self.email = email
            self.mobilePhone = mobilePhone
        if let profilePhotoUrl = URL(string: profilePhoto?.removingPercentEncoding ?? "") {
            self.profilePhoto = profilePhotoUrl.lastPathComponent
        }
            self.defaultAddressId = defaultAddressId
            self.defaultPaymentCardId = defaultPaymentCardId
            self.settings = settings
            self.preferences = preferences
            self.walletAmount = walletAmount
            self.referralCode = referralCode
            self._dataModel = dataModel ?? UserModel(id: id, firstName: firstName, lastName: lastName, email: email, mobilePhone: mobilePhone, profilePhoto: profilePhoto, defaultAddressId: defaultAddressId, defaultPaymentCardId: defaultPaymentCardId, walletAmount: walletAmount, referralCode: referralCode)
    }
    
    convenience init(original: User) {
        self.init (id: original.id,
            firstName: original.firstName,
            lastName: original.lastName,
            email: original.email,
            mobilePhone: original.mobilePhone,
            profilePhoto: original.profilePhoto,
            defaultAddressId: original.defaultAddressId,
            defaultPaymentCardId: original.defaultPaymentCardId,
            settings: original.settings.copy(),
            preferences: original.preferences.copy(),
            walletAmount: original.walletAmount,
            referralCode: original.referralCode)
    }
    
    func sync(_ user: User) {
        self.id = user.id
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.email = user.email
        self.mobilePhone = user.mobilePhone
        self.profilePhoto = user.profilePhoto
        self.defaultAddressId = user.defaultAddressId
        self.defaultPaymentCardId = user.defaultPaymentCardId
        self.settings.sync(user.settings)
        self.preferences.sync(user.preferences)
        self.walletAmount = user.walletAmount
        self.referralCode = user.referralCode
        syncDataModel() 
    }
}

extension User: DataModelWrapper {
    
    var dataModel: NSManagedObject {
        return _dataModel
    }
    
    func syncDataModel() {
        _dataModel.id = self.id as NSNumber
        _dataModel.firstName = self.firstName
        _dataModel.lastName = self.lastName
        _dataModel.email = self.email
        _dataModel.mobilePhone = self.mobilePhone
        _dataModel.profilePhoto = self.profilePhoto
        
        if let defaultAddressId = self.defaultAddressId {
            _dataModel.defaultAddressId = defaultAddressId as NSNumber
        }
        
        if let defaultPaymentCardId = self.defaultPaymentCardId {
            _dataModel.defaultPaymentCardId = defaultPaymentCardId as NSNumber
        }
        
        if let walletAmount = self.walletAmount {
            _dataModel.walletAmount = walletAmount as NSNumber
        }
        
        _dataModel.referralCode = self.referralCode
        saveDataModelChanges()
    }
    
    func saveDataModel() {
        LemonCoreDataManager.insert(objects: dataModel)
    }
}

extension User {
    convenience init(userModel: UserModel) {
        
        self.init(id: userModel.id.intValue,
            firstName: userModel.firstName,
            lastName: userModel.lastName,
            email: userModel.email,
            mobilePhone: userModel.mobilePhone,
            profilePhoto: userModel.profilePhoto,
            defaultAddressId: userModel.defaultAddressId?.intValue,
            defaultPaymentCardId: userModel.defaultPaymentCardId?.intValue,
            settings: Settings(),
            preferences: Preferences(),
            walletAmount: userModel.walletAmount?.doubleValue,
            referralCode: userModel.referralCode,
            dataModel: userModel)
    }
}

//
//  User.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import SwiftyJSON
import Bond
import PassKit


final class User: Copying, Codable {
    
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
    var isAdmin: Bool
    
    var defaultPaymentCardId: Int?    
    
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
        isAdmin: Bool) {
            
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
            self.isAdmin = isAdmin
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
            referralCode: original.referralCode,
            isAdmin: original.isAdmin)
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
        self.isAdmin = user.isAdmin
    }
}

func save(user: User) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(user) {
        let defaults = UserDefaults.standard
        defaults.set(encoded, forKey: "SavedUser")
        defaults.synchronize()
    }
}

func loadUser() -> User? {
    let decoder = JSONDecoder()
    let defaults = UserDefaults.standard
    if let decoded  = defaults.object(forKey: "SavedUser") as? Data {
        do {
            let user = try decoder.decode(User.self, from: decoded)
            return user
        } catch {
            return nil
        }
    }
    return nil
}

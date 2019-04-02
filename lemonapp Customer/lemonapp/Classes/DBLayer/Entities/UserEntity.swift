//
//  UserEntity.swift
//  EMBreakDepedencyRealm
//
//  Created by Ennio Masi on 10/07/2017.
//  Copyright © 2017 ennioma. All rights reserved.
//
import Foundation
import RealmSwift
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
    @objc dynamic var referralCode: String? = nil
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

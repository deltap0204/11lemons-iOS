//
//  UserWrapper.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit

final class UserWrapper {
    
    fileprivate let user: User
    
    let changedUser: User
    
    let id: Int
    
    let firstName: Observable<String>
    let lastName: Observable<String>
    let email: Observable<String?>
    let mobilePhone: Observable<String?>
    let profilePhoto: Observable<String?>
    let defaultAddressId: Observable<Int?>
    let defaultPaymentCardId: Observable<Int?>
    let defaultAddress: Observable<Address?> = Observable(nil)
    let addresses: Observable<[Address]> = Observable([])
    let defaultPaymentCard: Observable<PaymentCardProtocol?> = Observable(nil)
    let paymentCards: Observable<[PaymentCard]> = Observable([])
    let walletAmount = Observable<Double?>(nil)
    let referral = Observable<String?>(nil)
    
    let settingsDidChange: SafeReplayOneSubject<Void>
    
    let applePayCard: ApplePayCard?
    
    let settings: Observable<[Settings]> = Observable([])

    
    var activeAddresses: [Address] {
        return self.addresses.value.compactMap { !$0.deleted ? $0 : nil }
    }
    var activePaymentCards: [PaymentCard] {
        return self.paymentCards.value.compactMap { !$0.deleted ? $0 : nil }
    }
    
    var fullName: String {
        get {
            return firstName.value + " " + lastName.value
        }
    }
    
    init(user: User) {
        self.user = user
        changedUser = user.copy()
        self.id = user.id
        firstName = Observable(user.firstName)
        lastName = Observable(user.lastName)
        email = Observable(user.email)
        mobilePhone = Observable(user.mobilePhone)
        profilePhoto = Observable(user.profilePhoto)
        defaultAddressId = Observable(user.defaultAddressId)
        defaultPaymentCardId = Observable(user.defaultPaymentCardId)
        walletAmount.value = user.walletAmount
        settingsDidChange = user.settings.settingsDidChange
        referral.value = user.referralCode
        
        if ApplePayCard.isApplePayAvailable() {
            self.applePayCard = ApplePayCard()
        } else {
            self.applePayCard = nil
        }
        
        firstName.observeNext { [weak changedUser] in
            changedUser?.firstName = $0
        }
        lastName.observeNext { [weak changedUser] in
            changedUser?.lastName = $0
        }
        email.observeNext { [weak changedUser] in
            changedUser?.email = $0 ?? ""
        }
        mobilePhone.observeNext { [weak changedUser] in
            changedUser?.mobilePhone = $0 ?? ""
        }
        profilePhoto.observeNext { [weak changedUser] in
            changedUser?.profilePhoto = $0
        }
        defaultAddress.observeNext { [weak changedUser] in
            changedUser?.defaultAddressId = $0?.id ?? changedUser?.defaultAddressId
        }
        defaultPaymentCard.observeNext { [weak changedUser] in
            changedUser?.defaultPaymentCardId = $0?.id ?? changedUser?.defaultPaymentCardId
        }
        
        addresses.observeNext { [weak defaultAddressId] _ in
            defaultAddressId?.value = defaultAddressId?.value
        }
        addresses.observeNext { [weak defaultPaymentCardId] _ in
            defaultPaymentCardId?.value = defaultPaymentCardId?.value
        }
        
        defaultAddressId.observeNext { [weak self] defaultAddressId in
            if let defaultAddress = self?.activeAddresses.find({ $0.id == defaultAddressId }) {
                self?.defaultAddress.value = defaultAddress
            } else {
                self?.defaultAddress.value = self?.activeAddresses.first
            }
        }
        defaultPaymentCardId.observeNext { [weak self] defaultPaymentCardId in
            if let defaultPaymentCard = self?.activePaymentCards.find({ $0.id == defaultPaymentCardId }) {
                self?.defaultPaymentCard.value = defaultPaymentCard
            } else if let applePayCard = self?.applePayCard {
                self?.defaultPaymentCard.value = applePayCard
            } else {
                self?.defaultPaymentCard.value = self?.activePaymentCards.first
            }
            
        }
        
        
        //walletAmount.skip(first: 1).observeNext { [weak self] in
        walletAmount.skip(first: 1).observeNext { [weak self] in
            guard let self = self else {return}
            if let walletAmount = $0, self.user.walletAmount != walletAmount {
                self.changedUser.walletAmount = walletAmount
                self.user.walletAmount = walletAmount
                save(user: self.user)
            }
        }
        
        referral.observeNext { [weak self] in self?.changedUser.referralCode = $0 }
    }
    
    func refresh() {
        firstName.value = user.firstName
        lastName.value = user.lastName
        email.value = user.email
        mobilePhone.value = user.mobilePhone
        defaultAddressId.value = user.defaultAddressId
        defaultPaymentCardId.value = user.defaultPaymentCardId
        walletAmount.value = user.walletAmount
        changedUser.settings = user.settings.copy()
        changedUser.preferences = user.preferences.copy()
        changedUser.referralCode = user.referralCode
    }
    
    func saveChanges() {
        user.sync(changedUser)
        save(user: self.user)
    }
}

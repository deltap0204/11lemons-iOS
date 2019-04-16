//
//  DataProvider + DB.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//

import Foundation

extension DataProvider {
    func clearDB() {
        do {
            try Storage.deleteAll(AddressEntity.self)
            try Storage.deleteAll(OrderDetailsReceiptEntity.self)
            try Storage.deleteAll(ServiceEntity.self)
            try Storage.deleteAll(OrderGarmentEntity.self)
            try Storage.deleteAll(ProductEntity.self)
            try Storage.deleteAll(CategoryEntity.self)
            try Storage.deleteAll(AttributeEntity.self)
            try Storage.deleteAll(BillingAddressEntity.self)
            try Storage.deleteAll(AddressEntity.self)
            try Storage.deleteAll(DeliveryEntity.self)
            try Storage.deleteAll(OrderAmountEntity.self)
            try Storage.deleteAll(PaymentCardEntity.self)
            try Storage.deleteAll(OrderDetailEntity.self)
            try Storage.deleteAll(OrderImagesEntity.self)
            try Storage.deleteAll(SettingsEntity.self)
            try Storage.deleteAll(PreferencesEntity.self)
            try Storage.deleteAll(UserEntity.self)
            try Storage.deleteAll(OrderEntity.self)
            try Storage.deleteAll(WalletTransitionEntity.self)
        } catch (let error) {
            let appError = DeleteAllRealmError()
            track(error: appError, additionalInfo: appError.errorUserInfo)
        }
    }
    
    func getSavedDataInDB() {
        Storage.fetch(OrderEntity.self, predicate: nil, sorted: nil) {[weak self] (response) in
            let orders = response.compactMap( {Order(entity: $0)})
            self?.userOrders.replace(with: orders)
            self?.userDashboardItems.replace(with: self?.getDashboardItems() ?? [])
        }
        
    }
    
    public func saveOrderInDB(order: Order) {
        if self.isUserLogged {
            let orderEntity = OrderEntity.create(with: order)
            do {
                try Storage.save(object: orderEntity)
            } catch {
                let appError = SaveAdminOrderRealmError()
                track(error: appError, additionalInfo: appError.errorUserInfo)
            }
        }
    }
    
    public func saveOrdersInDB(orders: [Order]) {
        if self.isUserLogged {
            orders.forEach { (order) in
                let orderEntity = OrderEntity.create(with: order)
                do {
                    try Storage.save(object: orderEntity)
                } catch {
                    let appError = SaveAdminOrderRealmError()
                    track(error: appError, additionalInfo: appError.errorUserInfo)
                }
            }
            NotificationCenter.default.post(name: NotificationNames.eventTracker.realmSaveOrders, object: nil)
        }
    }
    
    public func saveProductsInDB(_ products: [Product]) {
        if self.isUserLogged {
            products.forEach { (product) in
                let productEntity = ProductEntity.create(with: product)
                do {
                    try Storage.save(object: productEntity)
                } catch {
                    let appError = SaveProductsRealmError()
                    track(error: appError, additionalInfo: appError.errorUserInfo)
                }
            }
            NotificationCenter.default.post(name: NotificationNames.eventTracker.realmSaveProduct, object: nil)
        }
    }
    
    func saveAddressInDB(address: Address) {
        if self.isUserLogged {
            let addressEntity = AddressEntity.create(with: address)
            do {
                try Storage.save(object: addressEntity)
            } catch {
                let appError = SaveAddressRealmError()
                track(error: appError, additionalInfo: appError.errorUserInfo)
            }
        }
    }
    
    func savePaymentCardInDB(card: PaymentCard) {
        if self.isUserLogged {
            let cardEntity = PaymentCardEntity.create(with: card)
            do {
                try Storage.save(object: cardEntity)
            } catch {
                let appError = SavePaymentCardRealmError()
                track(error: appError, additionalInfo: appError.errorUserInfo)
            }
        }
    }
    
    func saveWalletTransitionInDB(walletTransition: WalletTransition) {
        if self.isUserLogged {
            let walletTransitionEntity = WalletTransitionEntity.create(with: walletTransition)
            do {
                try Storage.save(object: walletTransitionEntity)
            } catch {
                let appError = SaveWalletTransitionRealmError()
                track(error: appError, additionalInfo: appError.errorUserInfo)
            }
        }
    }
    
    func deleteAllOrders() {
        do {
            try Storage.deleteAll(OrderEntity.self)
        } catch (let error) {
            let appError = DeleteAllRealmError()
            track(error: appError, additionalInfo: appError.errorUserInfo)
        }
    }
}

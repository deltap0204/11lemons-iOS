//
//  DataProvider + refresh.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//

import Foundation
extension DataProvider {
    func refreshFaqs(_ completion: @escaping () -> Void) {
        LemonAPI.getFaq().request().observeNext { [weak self] (faqResolver: EventResolver<[FaqItem]>) in
            do {
                let faqs = try faqResolver()
                self?.faqs.value = faqs
                completion()
            } catch {
                completion()
            }
            }.dispose(in: disposeBagBackend)
    }
    
    func refreshProducts() {
        LemonAPI.getProducts().request().observeNext { [weak self](resolver: EventResolver<[Product]>) in
            do {
                let products = try resolver()
                self?.products.value = Product.groupingProducts(products)
                self?.saveProductsInDB(products)
            } catch {}
            }.dispose(in: disposeBagBackend)
    }
    
    func refreshDeliveryPricing() {
        LemonAPI.getDeliveryOptions().request().observeNext { [weak self] (deliveryRespolver: EventResolver<[DeliveryPricing]>) in
            do {
                let options = try deliveryRespolver().filter { $0.active }
                if options.count == 3 {
                    self?.deliveryPricing.value = Array(options[0..<3])
                }
            } catch { }
            }.dispose(in: disposeBagBackend)
    }
    
    func refreshAddresses() {
        LemonAPI.getAddresses().request().observeNext { [weak self] (addressesResolver: EventResolver<[Address]>) in
            do {
                let addresses = try addressesResolver()
                self?.userWrapper?.addresses.value = addresses
            } catch {}
            }.dispose(in: disposeBagBackend)
    }
    
    func refreshPaymentCards() {
        LemonAPI.getPaymentCards().request().observeNext { [weak self](paymentCardsResolver: EventResolver<[PaymentCard]>) in
            do {
                let paymentCards = try paymentCardsResolver()
                self?.userWrapper?.paymentCards.value = paymentCards
            } catch {}
            }.dispose(in: disposeBagBackend)
    }
    
    func refreshPickupETA(_ completion: (()->())? = nil) {
        LemonAPI.getPickupETA().request().observeNext { [weak self] (resolver: EventResolver<String>) in
            let pickupETA = (Int((try? resolver()) ?? "45")) ?? Config.StandardPickupETA
            self?.pickupETA.value = pickupETA
            completion?()
            }.dispose(in: disposeBagBackend)
    }
    
    func refreshPaymentToken() {
        LemonAPI.getPaymentToken().request().observeNext { [weak self] (tokenResolver: EventResolver<String> ) in
            do {
                self?.paymentToken = try tokenResolver()
            } catch {}
            }.dispose(in: disposeBagBackend)
    }
    
    func refreshCloudClosetUpdates() {
        self.cloudClosetUpdates.next(self.cloudCloset.array.filter { !$0.viewed.value }.count)
    }
    
    func refreshUserOrders(_ onComplete: OrderListCompletion? = nil) {
        LemonAPI.getOrders().request().observeNext { [weak self] (result: EventResolver<[Order]>) in
            do {
                let orders = try result()
                self?.lastUpdateDate = Date()

                self?.saveOrdersInDB(orders: orders)
                self?.userOrders.replace(with: orders)
//                self?.userOrdersUpdates.next(self?.userOrders.array.flatMap { $0.viewed.value ? nil : $0 }.count ?? 0)
                if let userId = self?.userWrapper?.id {
                    _ = LemonAPI.getWallet(userId: userId).request().observeNext { (resolver: EventResolver<Wallet>) in
                        self?.wallet.value = try? resolver()
                        self?.walletUpdates.next(self?.wallet.value?.transitions.compactMap { !$0.viewed.value ? $0 : nil }.count ?? 0)
                        if let wallet = self?.wallet.value {
                            wallet.transitions.forEach { self?.saveWalletTransitionInDB(walletTransition: $0) }
                        }
                        DispatchQueue.main.async() {
                            self?.userDashboardItems.replace(with: self?.getDashboardItems() ?? [])
                            onComplete? { orders }
                        }
                    }
                } else {
                    self?.userDashboardItems.replace(with: self?.getDashboardItems() ?? [])
                    onComplete? { orders }
                }
                
                
            } catch let error {
//                LemonCoreDataManager.fetchAsync(OrderModel.self) { [weak self] in
//                    let orderModels = try? $0()
//                    let orders = orderModels??.map { Order(orderModel: $0) }.sorted { $0.id > $1.id }
//                    self?.userOrders.replace(with: orders ?? [])
//                    if let orders = orders, orders.count > 0 {
//                        onComplete? { return [] }
//                    } else {
//                        onComplete? { throw error}
//                    }
//                    LemonCoreDataManager.fetchAsync(WalletTransitionModel.self) {
//                        let transitionsModels = try? $0() ?? []
//                        let transitions = transitionsModels?.map { WalletTransition(walletTransitionModel: $0) } ?? []
//                        self?.wallet.value = Wallet(transitions: transitions, amount: self?.userWrapper?.walletAmount.value ?? 0)
//                        self?.userDashboardItems.replace(with: self?.getDashboardItems() ?? [])
//                    }
//                }
            }
        }.dispose(in: disposeBagBackend)
    }
    
    func refreshDepartments(_ onComplete: @escaping () -> Void) {
        LemonAPI.getDepartmentsAll().request().observeNext { [weak self] (result: EventResolver<[Service]>) in
            do {
                let departments = try result()
                self?.productsItems.replace(with: departments)
                onComplete()
            } catch let error {
                print(error)
                onComplete()
            }
            }.dispose(in: disposeBagBackend)
    }
    
    func refreshWallet() {
        self.updateUserData.execute {_ in 
            print("user updated")
        }
    }
}

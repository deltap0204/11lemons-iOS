//
//  DataProvider + refresh.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 20/02/2019.
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
    
    func refreshAdminOrdersFromBackend(_ onComplete: OrderListCompletion? = nil) {
        LemonAPI.getAllOrders().request().observeNext { [weak self] (result: EventResolver<[Order]>) in
            do {
                let orders = try result()
                self?.lastUpdateDate = Date()

                self?.deleteAllOrders()
                self?.saveOrdersInDB(orders: orders)
                self?.adminOrders.replace(with: orders)
                self?.adminDashboardItems.replace(with: self?.getDashboardItems() ?? [])
//                self?.adminOrdersUpdates.next(self?.adminOrders.array.compactMap { $0.viewed.value ? nil : $0 }.count ?? 0)
                
                onComplete? { orders }
            } catch let error {
                onComplete? { throw error}
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
}

//
//  DataProvider.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


typealias OrderListCompletion = (_ inner: EventResolver<[Order]>) -> Void

final class DataProvider {
    
    fileprivate static let updateDataTimeInterval: TimeInterval = 60 * 15
    
    static let sharedInstance = DataProvider()
    let DidSuggestNotificationsKey = "didSuggestNotifications"
    var paymentToken: String?
    
    var userWrapper: UserWrapper? = nil {
        didSet {
            userWrapperObserver.value = userWrapper
            UserDefaults.standard.synchronize()
        }
    }
    
    var lastUpdateDate: Date?
    
    let userWrapperObserver: Observable<UserWrapper?> = Observable(nil)
    
    let deliveryPricing = Observable(DeliveryPricing.defaultPricing())
    let faqs: Observable<[FaqItem]> = Observable([])
    
    let pickupETA: Observable<Int> = Observable(Config.StandardPickupETA)
    var disposeBagBackend = DisposeBag()
    let products: Observable<[Product]> = Observable([])
    let wallet: Observable<Wallet?> = Observable(nil)
    let walletUpdates = ReplayOneSubject<Int, NoError>()
    let cloudCloset = MutableObservableArray<Garment>([])
    let cloudClosetUpdates = ReplayOneSubject<Int, NoError>()
    
    let updateDataTimer: SwiftyTimer
    
    let userOrders: MutableObservableArray<Order> = MutableObservableArray([])
    
    let userDashboardItems = MutableObservableArray<DashboardItem>([])
    let productsItems: MutableObservableArray<Service> = MutableObservableArray([])
//    let userOrdersUpdates = ReplayOneSubject<Int, NoError>()

//    static let lockAdminOrdersQueue = dispatch_queue_create("com.11lemons.lemonapp.adminDashboardItems", nil)
    
    var defaultOrder: Order {
        let defaultOrder = Order()
        if let userWrapper = DataProvider.sharedInstance.userWrapper {
            defaultOrder.userId = userWrapper.id
            userWrapper.defaultAddress.observeNext { [weak defaultOrder] in
                if defaultOrder?.delivery.pickupAddress == nil || defaultOrder?.delivery.dropoffAddress == nil || $0 == nil {
                    defaultOrder?.delivery.pickupAddress = $0
                    defaultOrder?.delivery.dropoffAddress = $0
                }
            }
            userWrapper.defaultPaymentCard.observeNext { [weak defaultOrder] in
                if defaultOrder?.card == nil {
                    defaultOrder?.card = $0 as? PaymentCard
                }
            }
        }
        return defaultOrder;
    }
    
    func isAdminUser() -> Bool {
        return false
    }
    
    func refreshAllData() {
        self.refreshFaqs(){}
        self.refreshProducts()
        self.refreshDeliveryPricing()
        self.refreshAddresses()
        self.refreshPaymentCards()
        self.refreshPickupETA()
        self.refreshPaymentToken()
        self.refreshDepartments(){}
        // replace SaveData
//        LemonCoreDataManager.fetchAsync(GarmentModel.self) { [weak self] in
//
//            let garmentModels = try? $0() ?? []
//            let garments = garmentModels?.map { Garment(garmentModel: $0) } ?? []
//
//            let garmentsSorted = garments.sorted {
//                if $0.type?.id == $1.type?.id {
//                    return $0.id > $1.id
//                }
//                return $0.type?.id > $1.type?.id
//            }
//
//            self?.cloudCloset.replace(with: garmentsSorted)
//
//            self?.refreshCloudClosetUpdates()
//            self?.refreshCloudCloset()
//        }
    }
    
    
//    func refreshProducts(completion: () -> Void) {
//        _ = LemonAPI.GetProducts().request().observeNext { (resolver: () throws -> [Product]) in
//            do {
//                let products = try resolver()
//                self.products.value = Product.groupingProducts(products)
//                LemonCoreDataManager.replace(objects: products.flatMap { $0.dataModel as? ProductModel })
//                completion()
//            } catch {
//                completion()
//            }
//        }
//    }
    
    func refreshCloudCloset() {
        if let userId = self.userWrapper?.id {
            _ = LemonAPI.getCloudCloset(userId: userId).request().observeNext { [weak self] ( resolver: EventResolver<[Garment]> ) in
                do {
                    let garments = try resolver().sorted {
                        if $0.type?.id == $1.type?.id {
                            return $0.id > $1.id
                        }
                        return $0.type?.id > $1.type?.id
                    }
                    let garmentTypes = Array(Set(garments.flatMap { $0.type }))
                    let garmentBrands = Array(Set(garments.flatMap { $0.brand }))
                    // replace SaveData
//                    LemonCoreDataManager.replace(false, objects: garments.flatMap { $0.dataModel as? GarmentModel })
//                    LemonCoreDataManager.replace(false, objects: garmentTypes.flatMap { $0.dataModel as? GarmentTypeModel })
//                    LemonCoreDataManager.replace(false, objects: garmentBrands.flatMap { $0.dataModel as? GarmentBrandModel })
                    garments.forEach { garment in
                        garment.type = garmentTypes.find { garment.type == $0 }
                        garment.brand = garmentBrands.find { garment.brand == $0 }
//                        garment.bindModels()
                    }
                    self?.cloudCloset.replace(with: garments)
                    garments.forEach {
                        $0.viewed.skip(first: 1).observeNext { _ in
                            self?.refreshCloudClosetUpdates()
                        }
                    }
                    self?.refreshCloudClosetUpdates()
                } catch {}
            }
        }
    }
    
    var isUserLogged: Bool {
        return AccessToken.isExist()
    }
    
    func restoreData(_ complite:(() -> ())? = nil) {
        showLoadingOverlay()
        defer {
            hideLoadingOverlay()
            complite?()
        }
        
        if let user = loadUser() {
            self.userWrapper = UserWrapper(user: user)
        }
        
        self.getSavedDataInDB()
    }
    
    fileprivate init() {
        
        updateDataTimer = SwiftyTimer.init(timeInterval: DataProvider.updateDataTimeInterval, repeats: true)
        updateDataTimer.onTimer.observeNext { [weak self] in
            self?.updateUserData.execute {
                self?.userDashboardItems.replace(with: $0() ?? [])
            }
        }
        
        userOrders.skip(first: 1).observeNext { [weak self] in
            self?.updateUserOrderInfo()
            if let strongSelf = self {
                switch $0.change {
                case .deletes(let range):
                    //strongSelf.userDashboardItems.removeSubrange(range)
                    break
                    //TODO migration-check
                    //TODO investigate solution
                //Before migration code
                    
                //case .insert(let elements,let fromIndex):
                case .inserts(let indices):
                    //let dashboardItems = elements.map { $0 as DashboardItem }
                    //strongSelf.userDashboardItems.insertContentsOf(dashboardItems, atIndex: fromIndex)
                    break
 
                default:
                    break
                }
            }
        }
        
        wallet.observeNext { [weak self] in
            self?.userWrapper?.walletAmount.value = $0?.amount
            $0?.transitions.forEach {
                $0.viewed.skip(first: 1).observeNext { _ in
                    self?.walletUpdates.next(self?.wallet.value?.transitions.flatMap { !$0.viewed.value ? $0 : nil }.count ?? 0)
                }
            }
        }
        
        cloudClosetUpdates.map { $0 > 0 }.filter { $0 }.observeNext { [weak self] in
            self?.userWrapper?.changedUser.settings.cloudClosetEnabled = $0
            self?.userWrapper?.saveChanges()
        }
    }
    
    fileprivate func updateUserOrderInfo() {
        self.updateOrderInfo()
    }
    
    fileprivate func updateOrderInfo() {
        self.userOrders.array.forEach { order in
            let cards = self.userWrapper?.paymentCards.value.filter { card in
                return card.id == order.paymentId
            }
            order.card = cards?.first
            order.userId = self.userWrapper?.id
            order.viewed.skip(first: 1).observeNext { [weak self] _ in
//                self?.userOrdersUpdates.next(self?.userOrders.array.flatMap { $0.viewed.value ? nil : $0 }.count ?? 0)
            }
        }
    }
    
    var updateUserData: Action<()->[DashboardItem]?> {
        return Action { [weak self] in
            Signal { sink in
                if let userId = self?.userWrapper?.id {
                    _ = LemonAPI.getWallet(userId: userId).request().observeNext { [weak self] (resolver: EventResolver<Wallet>) in
                        self?.wallet.value = try? resolver()
                        self?.walletUpdates.next(self?.wallet.value?.transitions.compactMap { !$0.viewed.value ? $0 : nil }.count ?? 0)
                        if let wallet = self?.wallet.value  {
                            wallet.transitions.forEach { self?.saveWalletTransitionInDB(walletTransition: $0) }
                        }
                        let lastUpdateDate = self?.lastUpdateDate ?? Date()
//                        _ = LemonAPI.getOrdersUpdates(userId: userId, lastDate: lastUpdateDate).request().observeNext { [weak self] (resolver: EventResolver<[Order]>) in
//                            if let ordersUpdates = try? resolver() {
//                                if ordersUpdates.count > 0 {
//                                    self?.lastUpdateDate = lastUpdateDate
//                                    ordersUpdates.forEach { newOrder in
//                                        if let order = self?.userOrders.array.find( { $0.id == newOrder.id } ) {
//                                            order.sync(newOrder)
//                                        }
//                                    }
////                                    self?.userOrdersUpdates.next(self?.userOrders.array.compactMap { $0.viewed.value ? nil : $0 }.count ?? 0)
//                                    sink.completed(with: { return self?.getDashboardItems() })
//                                }
//                            }
//                        }
                        self?.refreshUserOrders() { [weak self] _ in
                            self?.lastUpdateDate = lastUpdateDate
                            sink.completed(with: { return self?.getDashboardItems() })
                        }
                    }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    func getDashboardItems() -> [DashboardItem] {
        let orders: [Order] = self.userOrders.array.compactMap { $0.status == .canceled || $0.status == .archived ? nil : $0 }
        
        let transitions = self.wallet.value?.transitions.compactMap { $0.archived ? nil : $0 } ?? []
        var dashboardItems = orders.compactMap { $0 as DashboardItem }
        dashboardItems.append(contentsOf: transitions.compactMap { $0 as DashboardItem })
        
        
        let sortedItems = dashboardItems.sorted {
            if $0.repeated == true {
                return true
            } else if $1.repeated == true {
                return false
            } else {
                guard let compareDate = $0.compareDate, let compareDate2 = $1.compareDate else {
                    return $0.id > $1.id
                }
                let compareResult = compareDate.compare(compareDate2 as Date)
                if compareResult == .orderedSame {
                    return $0.id > $1.id
                } else {
                    return compareResult == .orderedAscending
                }
            }
        }
        return sortedItems
    }

    
    
    
    func getInitialData() {
        refreshUserOrders() { [weak self] _ in
            guard let strongSelf = self else { return }
                strongSelf.refreshAllData()
        }
    }
    
    func clear() {
        self.disposeBagBackend = DisposeBag()
        self.cloudCloset.removeAll()
        self.clearDB()
        self.userWrapper = nil
        self.userOrders.replace(with: [])
        self.wallet.value = nil
        self.products.value = []
        self.faqs.value = []
        self.userDashboardItems.replace(with:[])
    }
}

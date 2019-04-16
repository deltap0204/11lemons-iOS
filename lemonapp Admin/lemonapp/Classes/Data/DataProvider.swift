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

class DataProvider {

    fileprivate static let updateDataTimeInterval: TimeInterval = 60 * 15
    let DidSuggestNotificationsKey = "didSuggestNotifications"
    
    static let sharedInstance = DataProvider()
    
    let adminOrders: MutableObservableArray<Order> = MutableObservableArray([])
    let adminDashboardItems = MutableObservableArray<DashboardItem>([])
    let productsItems: MutableObservableArray<Service> = MutableObservableArray([])
    let notificationSetting: MutableObservableArray<Service> = MutableObservableArray([])
//    let adminOrdersUpdates = ReplayOneSubject<Int, NoError>()
    let cloudCloset = MutableObservableArray<Garment>([])
    let cloudClosetUpdates = ReplayOneSubject<Int, NoError>()
    let deliveryPricing = Observable(DeliveryPricing.defaultPricing())
    
    var defaultOrder: Order {
        let defaultOrder = Order()
        if let userWrapper = DataProvider.sharedInstance.userWrapper {
            defaultOrder.userId = userWrapper.id
            _ = userWrapper.defaultAddress.observeNext { [weak defaultOrder] in
                if defaultOrder?.delivery.pickupAddress == nil || defaultOrder?.delivery.dropoffAddress == nil || $0 == nil {
                    defaultOrder?.delivery.pickupAddress = $0
                    defaultOrder?.delivery.dropoffAddress = $0
                }
            }
            _ = userWrapper.defaultPaymentCard.observeNext { [weak defaultOrder] in
                if defaultOrder?.card == nil {
                    defaultOrder?.card = $0 as? PaymentCard
                }
            }
        }
        return defaultOrder;
    }
    
    var disposeBag = DisposeBag()
    var disposeBagBackend = DisposeBag()
    let faqs: Observable<[FaqItem]> = Observable([])
    var isUserLogged: Bool {
        return AccessToken.isExist()
    }
    var lastUpdateDate: Date?
    var paymentToken: String?
     let pickupETA: Observable<Int> = Observable(Config.StandardPickupETA)
    let products: Observable<[Product]> = Observable([])
    
    
    let updateDataTimer: SwiftyTimer
    var userWrapper: UserWrapper? = nil {
        didSet {
            userWrapperObserver.value = userWrapper
            if let uw = userWrapper {
                UserDefaults.standard.set(uw.changedUser.isAdmin, forKey: LemonAPI.USER_ADMIN)
            } else {
                UserDefaults.standard.set(false, forKey: LemonAPI.USER_ADMIN)
            }
            UserDefaults.standard.synchronize()
        }
    }
    let userWrapperObserver: Observable<UserWrapper?> = Observable(nil)
    let wallet: Observable<Wallet?> = Observable(nil)
    let walletUpdates = ReplayOneSubject<Int, NoError>()

    
    fileprivate init() {
        
        self.updateDataTimer = SwiftyTimer.init(timeInterval: DataProvider.updateDataTimeInterval, repeats: true)
        self.updateDataTimer.onTimer.observeNext { [weak self] in
            self?.updateAdminData.execute {
                self?.adminDashboardItems.replace(with: $0() ?? [])
            }
        }.dispose(in: disposeBag)
        
        //        userOrders.skip(first: 1).observeNext { [weak self] in
        //            self?.updateUserOrderInfo()
        //            if let strongSelf = self {
        //                switch $0.change {
        //                case .deletes(let range):
        //                    //strongSelf.userDashboardItems.removeSubrange(range)
        //                    break
        //                    //TODO migration-check
        //                    //TODO investigate solution
        //                //Before migration code
        //
        //                //case .insert(let elements,let fromIndex):
        //                case .inserts(let indices):
        //                    //let dashboardItems = elements.map { $0 as DashboardItem }
        //                    //strongSelf.userDashboardItems.insertContentsOf(dashboardItems, atIndex: fromIndex)
        //                    break
        //
        //                default:
        //                    break
        //                }
        //            }
        //        }
        
        adminOrders.skip(first: 1).observeNext { [weak self] _ in
            self?.updateAdminOrderInfo()
//            if let strongSelf = self {
//                switch $0.change {
//                case .deletes(let range):
                    //strongSelf.adminDashboardItems.removeSubrange(range)
//                    break
                    //TODO migration-check
                    //TODO investigate solution
                    //Before migration code
                    /*
                     case .insert(let elements,let fromIndex):
                     let dashboardItems = elements.map { $0 as DashboardItem }
                     strongSelf.adminDashboardItems.insertContentsOf(dashboardItems, atIndex: fromIndex)
                     break
                     */
//                default:
//                    break
//                }
//            }
        }.dispose(in: disposeBag)
        
        wallet.observeNext { [weak self] in
            self?.userWrapper?.walletAmount.value = $0?.amount
            $0?.transitions.forEach {
                _ = $0.viewed.skip(first: 1).observeNext { _ in
                    self?.walletUpdates.next(self?.wallet.value?.transitions.compactMap { !$0.viewed.value ? $0 : nil }.count ?? 0)
                }
            }
        }.dispose(in: disposeBag)
        
        cloudClosetUpdates.map { $0 > 0 }.filter { $0 }.observeNext { [weak self] in
            self?.userWrapper?.changedUser.settings.cloudClosetEnabled = $0
            self?.userWrapper?.saveChanges()
        }.dispose(in: disposeBag)
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
        
//        self.refreshNotificationSetting{
//
//        }
        
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

    
    // lucas - this is harder to follow take some time to improve this one
    func refreshCloudCloset() {
        if let userId = self.userWrapper?.id {
            LemonAPI.getCloudCloset(userId: userId).request().observeNext { [weak self] ( resolver: EventResolver<[Garment]> ) in
                do {
                    let garments = try resolver().sorted {
                        if $0.type?.id == $1.type?.id {
                            return $0.id > $1.id
                        }
                        return $0.type?.id > $1.type?.id
                    }
                    let garmentTypes = Array(Set(garments.compactMap { $0.type }))
                    let garmentBrands = Array(Set(garments.compactMap { $0.brand }))
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
            }.dispose(in: disposeBagBackend)
        }
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

    fileprivate func updateAdminOrderInfo() {
        self.adminOrders.array.forEach { order in
            let cards = self.userWrapper?.paymentCards.value.filter { card in
                return card.id == order.paymentId
            }
            order.card = cards?.first
            order.userId = self.userWrapper?.id
//            _ = order.viewed.skip(first: 1).observeNext { [weak self] _ in
//                self?.adminOrdersUpdates.next(self?.adminOrders.array.compactMap { $0.viewed.value ? nil : $0 }.count ?? 0)
//            }
        }
    }
    
    var updateAdminData: Action<()->[DashboardItem]?> {
        return Action { [weak self] in
            Signal { sink in
                    self?.refreshAdminOrdersFromBackend() { [weak self] _ in
                        sink.completed(with: { return self?.getDashboardItems() })
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    func getDashboardItems() -> [DashboardItem] {
        var orders: [Order]
        orders = self.adminOrders.array.compactMap { $0.status == .canceled || $0.status == .archived ? nil : $0 }
        
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
        self.refreshAdminOrdersFromBackend() { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.refreshAllData()
        }
    }
    
    func clear() {
        self.disposeBagBackend = DisposeBag()
        self.userWrapper = nil
        self.adminOrders.removeAll()
        self.wallet.value = nil
        self.products.value = []
        self.faqs.value = []
        self.adminDashboardItems.removeAll()
        self.cloudCloset.removeAll()
        self.clearDB()
    }
}

extension DataProvider {
    private func clearDB() {
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
        } catch (let error) {
            let appError = DeleteAllRealmError()
            track(error: appError, additionalInfo: appError.errorUserInfo)
        }
    }
    
    private func getSavedDataInDB() {
        Storage.fetch(OrderEntity.self, predicate: nil, sorted: nil) {[weak self] (response) in
            let orders = response.compactMap( {Order(entity: $0)})
            self?.adminOrders.replace(with: orders)
            self?.adminDashboardItems.replace(with: self?.getDashboardItems() ?? [])
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
    
    func deleteAllOrders() {
        do {
            try Storage.deleteAll(OrderEntity.self)
        } catch (let error) {
            let appError = DeleteAllRealmError()
            track(error: appError, additionalInfo: appError.errorUserInfo)
        }
    }
}

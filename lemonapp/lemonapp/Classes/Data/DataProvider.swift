//
//  DataProvider.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UserNotifications
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
    
    var paymentToken: String?
    
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
    
    var lastUpdateDate: Date?
    
    let userWrapperObserver: Observable<UserWrapper?> = Observable(nil)
    
    let deliveryPricing = Observable(DeliveryPricing.defaultPricing())
    let faqs: Observable<[FaqItem]> = Observable([])
    
    let pickupETA: Observable<Int> = Observable(Config.StandardPickupETA)
    
    let products: Observable<[Product]> = Observable([])
    let wallet: Observable<Wallet?> = Observable(nil)
    let walletUpdates = ReplayOneSubject<Int, NoError>()
    let cloudCloset = MutableObservableArray<Garment>([])
    let cloudClosetUpdates = ReplayOneSubject<Int, NoError>()
    
    let updateDataTimer: SwiftyTimer
    
    let userOrders: MutableObservableArray<Order> = MutableObservableArray([])
    let adminOrders: MutableObservableArray<Order> = MutableObservableArray([])
    
    let userDashboardItems = MutableObservableArray<DashboardItem>([])
    let adminDashboardItems = MutableObservableArray<DashboardItem>([])
    
    let userOrdersUpdates = ReplayOneSubject<Int, NoError>()
    let adminOrdersUpdates = ReplayOneSubject<Int, NoError>()

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
        if UserDefaults.standard.object(forKey: LemonAPI.USER_ADMIN) != nil {
            if let isAdmin = UserDefaults.standard.object(forKey: LemonAPI.USER_ADMIN) as? Bool {
                return isAdmin
            }
        }
        return false
    }
    
    func refreshData() {
        
        LemonCoreDataManager.fetchAsync(FAQItemModel.self) { [weak self] in
            let FAQItemModels = try? $0() ?? []
            self?.faqs.value = FAQItemModels?.map { FaqItem(faqItemModel: $0) } ?? []
            
            _ = LemonAPI.getFaq().request().observeNext { (faqResolver: EventResolver<[FaqItem]>) in
                do {
                    let faqs = try faqResolver()
                    self?.faqs.value = faqs
                    LemonCoreDataManager.replace(objects: faqs.flatMap { $0.dataModel as? FAQItemModel })
                } catch { }
            }
        }
        
        LemonCoreDataManager.fetchAsync(ProductModel.self) { [weak self] in
            let productModels = try? $0() ?? []
            let products = productModels?.map { Product(productModel: $0) } ?? []
            self?.products.value = Product.groupingProducts(products)
            //TODO: lucas
            _ = LemonAPI.getProducts().request().observeNext { (resolver: EventResolver<[Product]>) in
                do {
                    let products = try resolver()
                    self?.products.value = Product.groupingProducts(products)
                    LemonCoreDataManager.replace(objects: products.flatMap { $0.dataModel as? ProductModel })
                } catch {}
            }
            
        }
        
        LemonCoreDataManager.fetchAsync(DeliveryPricingModel.self) { [weak self] in
            let optionModels = (try? $0()) ?? []
            let options = optionModels?.map { DeliveryPricing(deliveryPricingModel: $0) } ?? DeliveryPricing.defaultPricing()
            self?.deliveryPricing.value = options
            _ = LemonAPI.getDeliveryOptions().request().observeNext { (deliveryRespolver: EventResolver<[DeliveryPricing]>) in
                do {
                    let options = try deliveryRespolver().filter { $0.active }
                    LemonCoreDataManager.replace(objects: options.flatMap { $0.dataModel as? DeliveryPricingModel })
                    if options.count == 3 {
                        DataProvider.sharedInstance.deliveryPricing.value = Array(options[0..<3])
                    }
                } catch { }
            }
        }
        
        LemonCoreDataManager.fetchAsync(AddressModel.self) { [weak userWrapper] in
            let addressModels = try? $0() ?? []
            let addresses = addressModels?.map { Address(addressModel: $0) } ?? []
            userWrapper?.addresses.value = addresses
            _ = LemonAPI.getAddresses().request().observeNext { (addressesResolver: EventResolver<[Address]>) in
                do {
                    let addresses = try addressesResolver()
                    userWrapper?.addresses.value = addresses
                    LemonCoreDataManager.replace(objects: addresses.flatMap { $0.dataModel as? AddressModel })
                    
                } catch {}
            }
        }
        
        LemonCoreDataManager.fetchAsync(PaymentCardModel.self) { [weak self] in
            let paymentCardModels = try? $0() ?? []
            let paymentCards = paymentCardModels?.map { PaymentCard(paymentCardModel: $0) } ?? []
            self?.userWrapper?.paymentCards.value = paymentCards
            self?.updateUserOrderInfo()
            _ = LemonAPI.getPaymentCards().request().observeNext { (paymentCardsResolver: EventResolver<[PaymentCard]>) in
                do {
                    let paymentCards = try paymentCardsResolver()
                    self?.userWrapper?.paymentCards.value = paymentCards
                    LemonCoreDataManager.replace(objects: paymentCards.flatMap { $0.dataModel as? PaymentCardModel })
                    self?.updateUserOrderInfo()
                } catch {}
            }
        }
        
        refreshPickupETA()
        
        _ = LemonAPI.getPaymentToken().request().observeNext { [weak self] (tokenResolver: EventResolver<String> ) in
            do {
                self?.paymentToken = try tokenResolver()
            } catch {}
        }
        
        LemonCoreDataManager.fetchAsync(GarmentModel.self) { [weak self] in
            
            let garmentModels = try? $0() ?? []
            let garments = garmentModels?.map { Garment(garmentModel: $0) } ?? []
            
            let garmentsSorted = garments.sorted {
                if $0.type?.id == $1.type?.id {
                    return $0.id > $1.id
                }
                return $0.type?.id > $1.type?.id
            }
            
            self?.cloudCloset.replace(with: garmentsSorted)
            
            self?.refreshCloudClosetUpdates()
            self?.refreshCloudCloset()
        }
    }
    
    fileprivate func refreshCloudClosetUpdates() {
        self.cloudClosetUpdates.next(self.cloudCloset.array.filter { !$0.viewed.value }.count)
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
                    LemonCoreDataManager.replace(false, objects: garments.flatMap { $0.dataModel as? GarmentModel })
                    LemonCoreDataManager.replace(false, objects: garmentTypes.flatMap { $0.dataModel as? GarmentTypeModel })
                    LemonCoreDataManager.replace(false, objects: garmentBrands.flatMap { $0.dataModel as? GarmentBrandModel })
                    garments.forEach { garment in
                        garment.type = garmentTypes.find { garment.type == $0 }
                        garment.brand = garmentBrands.find { garment.brand == $0 }
                        garment.bindModels()
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
    
    
    func refreshFAQ(_ completion: @escaping () -> Void) {
        
        _ = LemonAPI.getFaq().request().observeNext { (faqResolver: EventResolver<[FaqItem]>) in
            do {
                let faqs = try faqResolver()
                self.faqs.value = faqs
                LemonCoreDataManager.replace(objects: faqs.flatMap { $0.dataModel as? FAQItemModel })
                completion()
            } catch {
                completion()
            }
        }
    }
    
    
    var isUserLogged: Bool {
        return AccessToken.isExist()
    }
    
    func restoreData(_ complite:(() -> ())? = nil) {
        showLoadingOverlay()
        LemonCoreDataManager.fetchAsync(UserModel.self) { [weak self] in
            defer {
                hideLoadingOverlay()
                complite?()
            }
            do {
                if let userModel = try $0()?.first {
                    let user = User(userModel: userModel)
                    self?.userWrapper = UserWrapper(user: user)
                }
            } catch {}
        }
    }
    
    fileprivate init() {
        
        updateDataTimer = SwiftyTimer.init(timeInterval: DataProvider.updateDataTimeInterval, repeats: true)
        updateDataTimer.onTimer.observeNext { [weak self] in
            self?.updateUserData.execute {
                self?.userDashboardItems.replace(with: $0() ?? [])
            }
            self?.updateAdminData.execute {
                self?.adminDashboardItems.replace(with: $0() ?? [])
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
        
        adminOrders.skip(first: 1).observeNext { [weak self] in
            self?.updateAdminOrderInfo()
            if let strongSelf = self {
                switch $0.change {
                case .deletes(let range):
                    //strongSelf.adminDashboardItems.removeSubrange(range)
                    break
                    //TODO migration-check
                    //TODO investigate solution
                //Before migration code
                    /*
                case .insert(let elements,let fromIndex):
                    let dashboardItems = elements.map { $0 as DashboardItem }
                    strongSelf.adminDashboardItems.insertContentsOf(dashboardItems, atIndex: fromIndex)
                    break
 */
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
        self.updateOrderInfo(false)
    }
    
    
    fileprivate func updateAdminOrderInfo() {
        self.updateOrderInfo(true)
    }
    
    fileprivate func updateOrderInfo(_ isAdmin: Bool) {
        if isAdmin {
            self.adminOrders.array.forEach { order in
                let cards = self.userWrapper?.paymentCards.value.filter { card in
                    return card.id == order.paymentId
                }
                order.card = cards?.first
                order.userId = self.userWrapper?.id
                order.viewed.skip(first: 1).observeNext { [weak self] _ in
                    self?.adminOrdersUpdates.next(self?.adminOrders.array.flatMap { $0.viewed.value ? nil : $0 }.count ?? 0)
                }
            }
        } else {
            self.userOrders.array.forEach { order in
                let cards = self.userWrapper?.paymentCards.value.filter { card in
                    return card.id == order.paymentId
                }
                order.card = cards?.first
                order.userId = self.userWrapper?.id
                order.viewed.skip(first: 1).observeNext { [weak self] _ in
                    self?.userOrdersUpdates.next(self?.userOrders.array.flatMap { $0.viewed.value ? nil : $0 }.count ?? 0)
                }
            }
        }
    }
    
    var updateUserData: Action<()->[DashboardItem]?> {
        return Action { [weak self] in
            Signal { sink in
                if let userId = self?.userWrapper?.id {
                    _ = LemonAPI.getWallet(userId: userId).request().observeNext { [weak self] (resolver: EventResolver<Wallet>) in
                        self?.wallet.value = try? resolver()
                        self?.walletUpdates.next(self?.wallet.value?.transitions.flatMap { !$0.viewed.value ? $0 : nil }.count ?? 0)
                        if let transitions = self?.wallet.value?.transitions {
                            LemonCoreDataManager.replace(objects: transitions.flatMap { $0.dataModel as? WalletTransitionModel })
                        }
                        let lastUpdateDate = self?.lastUpdateDate ?? Date()
                        _ = LemonAPI.getOrdersUpdates(userId: userId, lastDate: lastUpdateDate).request().observeNext { [weak self] (resolver: EventResolver<[Order]>) in
                            if let ordersUpdates = try? resolver() {
                                if ordersUpdates.count > 0 {
                                    self?.lastUpdateDate = lastUpdateDate
                                    ordersUpdates.forEach { newOrder in
                                        if let order = self?.userOrders.array.find( { $0.id == newOrder.id } ) {
                                            order.sync(newOrder)
                                        }
                                    }
                                    self?.userOrdersUpdates.next(self?.userOrders.array.flatMap { $0.viewed.value ? nil : $0 }.count ?? 0)
                                    sink.completed(with: { return self?.getDashboardItems(false) })
                                }
                            }
                        }
                    }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    var updateAdminData: Action<()->[DashboardItem]?> {
        return Action { [weak self] in
            Signal { sink in
                if let userId = self?.userWrapper?.id {
                    let lastUpdateDate = self?.lastUpdateDate ?? Date()
                    _ = LemonAPI.getOrdersUpdates(userId: userId, lastDate: lastUpdateDate).request().observeNext { [weak self] (resolver: EventResolver<[Order]>) in
                        if let ordersUpdates = try? resolver() {
                            if ordersUpdates.count > 0 {
                                self?.lastUpdateDate = lastUpdateDate
                                ordersUpdates.forEach { newOrder in
                                    if let order = self?.adminOrders.array.find( { $0.id == newOrder.id } ) {
                                        order.sync(newOrder)
                                    }
                                }
                                self?.adminOrdersUpdates.next(self?.adminOrders.array.flatMap { $0.viewed.value ? nil : $0 }.count ?? 0)
                                sink.completed(with: { return self?.getDashboardItems(true) })
                            }
                        }
                    }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    fileprivate func getDashboardItems(_ isAdmin: Bool) -> [DashboardItem] {
        var orders: [Order]
        if isAdmin {
            orders = self.adminOrders.array.flatMap { $0.status == .canceled || $0.status == .archived ? nil : $0 }
        } else {
            orders = self.userOrders.array.flatMap { $0.status == .canceled || $0.status == .archived ? nil : $0 }
        }
        
        let transitions = self.wallet.value?.transitions.flatMap { $0.archived ? nil : $0 } ?? []
        var dashboardItems = orders.flatMap { $0 as DashboardItem }
        dashboardItems.append(contentsOf: transitions.flatMap { $0 as DashboardItem })
        
        
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
    
    func refreshPickupETA(_ completion: (()->())? = nil) {
        _ = LemonAPI.getPickupETA().request().observeNext { [weak self] (resolver: EventResolver<String>) in
            let pickupETA = (Int((try? resolver()) ?? "45")) ?? Config.StandardPickupETA
            self?.pickupETA.value = pickupETA
            completion?()
        }
    }
    
    func refreshAdminOrders(_ onComplete: OrderListCompletion? = nil) {
        _ = LemonAPI.getAllOrders().request().observeNext { [weak self] (result: EventResolver<[Order]>) in
            do {
                let orders = try result()
                self?.lastUpdateDate = Date()
                let orderDetail = orders.flatMap { $0.orderDetails }.flatMap { $0 }
                LemonCoreDataManager.insert(false, objects: orderDetail.flatMap { $0.product?.dataModel.managedObjectContext == nil ? $0.product?.dataModel as? ProductModel : nil })
                LemonCoreDataManager.replace(false, objects: orderDetail.flatMap { $0.dataModel as? OrderDetailsModel })
                LemonCoreDataManager.replace(false, objects: orders.flatMap { $0.dataModel as? OrderModel })
                orders.forEach { $0.syncDataModel() }
                
                self?.adminOrders.replace(with: orders)
                
                self?.adminOrdersUpdates.next(self?.adminOrders.array.flatMap { $0.viewed.value ? nil : $0 }.count ?? 0)
                self?.adminDashboardItems.replace(with: self?.getDashboardItems(true) ?? [])
                onComplete? { orders }
            } catch let error {
                LemonCoreDataManager.fetchAsync(OrderModel.self) { [weak self] in
                    let orderModels = try? $0()
                    let orders = orderModels??.map { Order(orderModel: $0) }.sorted { $0.id > $1.id }
                    self?.adminOrders.replace(with: orders ?? [])
                    if let orders = orders, orders.count > 0 {
                        onComplete? { return [] }
                    } else {
                        onComplete? { throw error}
                    }
                }
            }
        }
    }
    
    func refreshUserOrders(_ onComplete: OrderListCompletion? = nil) {
        _ = LemonAPI.getOrders().request().observeNext { [weak self] (result: EventResolver<[Order]>) in
            do {
                let orders = try result()
                self?.lastUpdateDate = Date()
                    
                let orderDetail = orders.flatMap { $0.orderDetails }.flatMap { $0 }
                
                LemonCoreDataManager.insert(false, objects: orderDetail.flatMap { $0.product?.dataModel.managedObjectContext == nil ? $0.product?.dataModel as? ProductModel : nil })
                LemonCoreDataManager.replace(false, objects: orderDetail.flatMap { $0.dataModel as? OrderDetailsModel })
                LemonCoreDataManager.replace(false, objects: orders.flatMap { $0.dataModel as? OrderModel })
                orders.forEach { $0.syncDataModel() }
                self?.userOrders.replace(with: orders)
                self?.userOrdersUpdates.next(self?.userOrders.array.flatMap { $0.viewed.value ? nil : $0 }.count ?? 0)
                if let userId = self?.userWrapper?.id {
                    _ = LemonAPI.getWallet(userId: userId).request().observeNext { (resolver: EventResolver<Wallet>) in
                        self?.wallet.value = try? resolver()
                        self?.walletUpdates.next(self?.wallet.value?.transitions.flatMap { !$0.viewed.value ? $0 : nil }.count ?? 0)
                        if let transitions = self?.wallet.value?.transitions {
                            LemonCoreDataManager.replace(objects: transitions.flatMap { $0.dataModel as? WalletTransitionModel })
                        }
                        DispatchQueue.main.async() {
                            self?.userDashboardItems.replace(with: self?.getDashboardItems(false) ?? [])
                            onComplete? { orders }
                        }
                    }
                } else {
                    self?.userDashboardItems.replace(with: self?.getDashboardItems(false) ?? [])
                    onComplete? { orders }
                }
                
                
            } catch let error {
                LemonCoreDataManager.fetchAsync(OrderModel.self) { [weak self] in
                    let orderModels = try? $0()
                    let orders = orderModels??.map { Order(orderModel: $0) }.sorted { $0.id > $1.id }
                    self?.userOrders.replace(with: orders ?? [])
                    if let orders = orders, orders.count > 0 {
                        onComplete? { return [] }
                    } else {
                        onComplete? { throw error}
                    }
                    LemonCoreDataManager.fetchAsync(WalletTransitionModel.self) {
                        let transitionsModels = try? $0() ?? []
                        let transitions = transitionsModels?.map { WalletTransition(walletTransitionModel: $0) } ?? []
                        self?.wallet.value = Wallet(transitions: transitions, amount: self?.userWrapper?.walletAmount.value ?? 0)
                        self?.userDashboardItems.replace(with: self?.getDashboardItems(false) ?? [])
                    }
                }
            }
        }
    }
    
    func getInitialData() {
        refreshUserOrders() { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.refreshAdminOrders() { [weak self] _ in
                guard let strongSelf2 = self else { return }
                strongSelf2.refreshData()
            }
        }
    }
    
    func clear() {
        self.userWrapper = nil
        self.userOrders.replace(with: [])
        self.adminOrders.replace(with: [])
        self.wallet.value = nil
        self.products.value = []
        self.faqs.value = []
        self.userDashboardItems.replace(with:[])
        self.adminDashboardItems.replace(with: [])
    }
    
    
    func registerForPushes() {
        if Config.ShouldRegisterForPushes {
        let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func rememberDevicePushNotificationToken(_ deviceToken: Data) {
        let hub = SBNotificationHub(connectionString: Config.HubListenAccess, notificationHubPath: Config.HubName)
        let userId = _ = LemonAPI.userId ?? 0
        
        //let tagSet = Set<NSObject>(arrayLiteral: "\(userId)")
        let tagSet = Set(arrayLiteral: "\(userId)")
        
        print(tagSet)
        print("11lemons: will register device token for userId:\(userId)")
        hub?.registerNative(withDeviceToken: deviceToken, tags: tagSet) { [weak self] error in
            if let error = error {
                print("11lemons: error in registering on 11lemons backend \(error.localizedDescription)")
            } else {
                print("11lemons: registered on 11lemons backend")
                print("11lemons: will try to enable pushes in user settings")
                if let changedUser = self?.userWrapper?.changedUser {
                    
                    changedUser.settings.pushEnabled = true
                    _ = LemonAPI.editProfile(user: changedUser).request().observeNext { (resolver: EventResolver<User>) in
                        do {
                            let user = try resolver()
                            self?.userWrapper?.saveChanges()
                            user.settings.save()
                            print("11lemons: enabled pushes in user settings")
                        } catch {
                            self?.userWrapper?.refresh()
                            print("11lemons: failed to enable pushes in user settings")
                        }
                    }
                }
            }
        }
    }
    
    fileprivate let DidSuggestNotificationsKey = "didSuggestNotifications"
    
    func suggestNotificationsAlert() -> SuggestNotificationViewController? {
        let defaults = UserDefaults.standard
        if let userId = userWrapper?.id, defaults.bool(forKey: DidSuggestNotificationsKey + "\(userId)") {
            return nil
        }
        
        let viewController = SuggestNotificationViewController.fromNib()
        return viewController
    }
    
    func setDidShowNotifications() {
        if let userId = userWrapper?.id {
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: DidSuggestNotificationsKey + "\(userId)")
            defaults.synchronize()
        }
    }
}

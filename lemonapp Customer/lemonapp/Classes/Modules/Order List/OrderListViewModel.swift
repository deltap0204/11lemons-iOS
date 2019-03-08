//
//  OrderListViewModel.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation
import Bond
import PassKit
import Braintree
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


final class OrderListViewModel : ViewModel {
    
    let dashboardItems: MutableObservableArray<DashboardItem>
    var dashboardViewModels = MutableObservableArray<ViewModel>([])
    let walletViewModel: Observable<UserViewModel?> = Observable(nil)
    
    let pickupETA: Observable<Int> = Observable(Config.StandardPickupETA)
    
    let userWalletBalance: Observable<Double?> = Observable(0)
    
    //let isNewItems = SafeSignal<Bool>(replayLength: 1)
    let isNewItems = ReplayOneSubject<Bool, NoError>()
    
    fileprivate let callString = "(914) 249-9534"
    fileprivate let textString = "(914) 249-9534"
    
    var phoneToCall: URL? {
        let phone = phoneFromString(callString)
        if let url = URL(string: "tel:\(phone)"), UIApplication.shared.canOpenURL(url) {
            return url
        }
        return nil
    }
    
    var phoneToText: String {
        return phoneFromString(textString)
    }
    
    fileprivate func phoneFromString(_ string: String) -> String {
        let phone = (string.components(separatedBy: CharacterSet(charactersIn: "0123456789-+()").inverted) as NSArray).componentsJoined(by: "")
        return phone
    }
    
    let shouldHideHints: SafeSignal<Bool>
    var orderedAscending = false
    
    func archiveWalletTransition(_ walletTransition: WalletTransition) -> Action<() throws -> ()> {
        return Action { [weak self] in
            Signal { sink in
                showLoadingOverlay()
                _ = LemonAPI.archiveWalletTransition(walletTransition: walletTransition).request().observeNext { (resolver: EventResolver<Void>) in
                    do {
                        hideLoadingOverlay()
                        try resolver()
                        walletTransition.archived = true
                        walletTransition.syncDataModel()
                        let dashboardItem = walletTransition as DashboardItem
                        if let walletTransitionIndex = self?.dashboardItems.array.index(where: { $0 == dashboardItem }) {
                            self?.dashboardItems.remove(at: walletTransitionIndex)
                        }
                    } catch let error {
                        sink.completed(with: { throw error })
                    }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    func archiveOrder(_ order: Order) -> Action<() throws -> ()> {
        return Action { [weak self] in
            Signal { sink in
                showLoadingOverlay()
                _ = LemonAPI.archiveOrder(order: order).request().observeNext { (resolver: EventResolver<Void>) in
                    do {
                        hideLoadingOverlay()
                        try resolver()
                        order.status = .archived
                        order.syncDataModel()
                        let dashboardItem = order as DashboardItem
                        if let orderIndex = self?.dashboardItems.array.index(where: { $0 == dashboardItem }) {
                            self?.dashboardItems.remove(at: orderIndex)
                        }
                    } catch let error {
                        sink.completed(with: { throw error })
                    }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    func cancelOrder(_ order: Order, fromViewController viewController: UIViewController) -> CancelOrderFlow {
        return CancelOrderFlow(withOrder: order, fromViewController: viewController) { [weak self] didCancel, success in
            if didCancel {
                order.status = .canceled
                order.syncDataModel()
                let dashboardItem = order as DashboardItem
                if let orderIndex = self?.dashboardItems.array.index(where: { $0 == dashboardItem }) {
                    self?.dashboardItems.remove(at: orderIndex)
                }
            }
        }
    }
    
    init() {
        
        self.dashboardItems = DataProvider.sharedInstance.userDashboardItems
        
        shouldHideHints = dashboardItems.map { [weak dashboardItems] _ in dashboardItems?.count > 0 }
        
        dashboardItems.observeNext { [weak self] event in
            //switch event.operation {
            switch event.change {
            case .deletes(let range):
                //self?.dashboardViewModels.removeSubrange(range)
                range.forEach {
                    self?.dashboardViewModels.remove(at: $0)
                }
                break
            default:
                if let strongSelf = self {
                    let auxArray: [ViewModel] = strongSelf.dashboardItems.array.compactMap {
                        if let order = $0 as? Order {
                            return OrderCellViewModel(order: order)
                        } else if let walletTransition = $0 as? WalletTransition {
                            return WalletTransitionCellViewModel(walletTransition: walletTransition)
                        }
                        return nil
                    }
                    strongSelf.dashboardViewModels.replace(with: auxArray)
                }
            }
        }
        
        DataProvider.sharedInstance.userWrapperObserver.observeNext { [weak self] in
            if let userWrapper = $0 {
                self?.walletViewModel.value = UserViewModel(userWrapper:userWrapper)
                self?.userWalletBalance.next(userWrapper.walletAmount.value)
                self?.commonAddressContainerViewModel = CommonContainerViewModel(userWrapper: userWrapper, screenIndetifier: .AddressScreen)
                self?.commonPaymentCardContainerViewModel = CommonContainerViewModel(userWrapper: userWrapper, screenIndetifier: .PaymentCardScreen)
                self?.quickOrder.value = DataProvider.sharedInstance.defaultOrder
            } else {
                self?.walletViewModel.value = nil
            }
        }
        quickOrder.map { $0 != nil }.bind(to: isQuickOrderEnabled)
        
        DataProvider.sharedInstance.cloudClosetUpdates.map { $0 > 0 }.bind(to: isNewItems)
    }
    
    func sortOrders(_ object1:ViewModel, object2:ViewModel) -> Bool {
        guard let object1 = object1 as? OrderCellViewModel else { return false; }
        guard let object2 = object2 as? OrderCellViewModel else { return false; }
        
        let order = orderedAscending ? ComparisonResult.orderedAscending : ComparisonResult.orderedDescending
        if let lastModified1 = object1.lastModified, let lastModified2 = object2.lastModified{
            return lastModified1.compare(lastModified2 as Date) == order
        }
        return false
    }
    
    func reorderBySearchString(_ searchText: String) {
        //dashboardViewModels.array = dashboardItems.array.flatMap {
        let auxArray: [ViewModel] = dashboardItems.array.flatMap {
            if let order = $0 as? Order {
                if (searchText.count == 0) {
                    return OrderCellViewModel(order: order)
                } else {
                    let orderNumber: String = String(order.id)
                    
                    if orderNumber.range(of: searchText, options: .caseInsensitive) != nil {
                        return OrderCellViewModel(order: order)
                    }
                    else {
                        return nil
                    }
                }
            }
            return nil
        }
        dashboardViewModels.replace(with: auxArray)
    }
    
    func update(_ completion: ( () -> Void )? = nil) {
        DataProvider.sharedInstance.refreshPickupETA()
        DataProvider.sharedInstance.refreshUserOrders() { _ in completion?() }
        DataProvider.sharedInstance.refreshCloudCloset()
    }
    
    // QUICK ORDER
    
    let quickOrder: Observable<Order?> = Observable(nil)
    //let quickOrderCreated: SafeSignal<Void> = SafeSignal()
    let quickOrderCreated = SafeReplaySubject<Void>()
    //var quickOrderCanceled: SafeSignal<Void> = SafeSignal()
    var quickOrderCanceled = SafeReplaySubject<Void>()
    let isQuickOrderEnabled: Observable<Bool> = Observable(true)
    var commonAddressContainerViewModel: CommonContainerViewModel?
    var commonPaymentCardContainerViewModel: CommonContainerViewModel?
    
    var newAddressAction: ((_  complition: @escaping (_ result: Address) -> ()) -> ())?
    var newPaymentCardAction: ((_ complition: @escaping (_ result: PaymentCard) -> ()) -> ())?
    
    var checkAddressRequest: Action<() throws -> [LocationData]> {
        return Action { [weak self] in
            return Signal/*(replayLength: 1)*/ { sink in
                if let zip = self?.quickOrder.value?.delivery.pickupAddress?.zip {
                    _ = LemonAPI.validateZip(zip: zip).request().observeNext { (resolver: @escaping EventResolver<[LocationData]>) in
                        sink.completed(with:  { return try resolver() } )
                    }
                } else {
                    sink.completed(with:  { return [] } )
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    var sendOrder: Action<() throws -> Order> {
        return Action { [weak self] in
            Signal { [weak self] sink in
                guard let order = self?.quickOrder.value else { /*return nil*/ return BlockDisposable {} }
                _ = LemonAPI.addOrder(order: order).request().observeNext { (result: EventResolver<Order>)  in
                    do {
                        let order = try result()
                        LemonCoreDataManager.insert(objects: order.dataModel)
                        order.syncDataModel()
                        sink.completed(with: { return order })
                    } catch let error {
                        sink.completed(with: { throw error })
                    }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    func createQuickOrder<T: PKPaymentAuthorizationViewControllerDelegate>(_ vc: T) where T: UIViewController {
        guard let quickOrder = quickOrder.value else { return }
        let isAddressExists = quickOrder.delivery.pickupAddress != nil
        let isPaymentCardExists = quickOrder.card != nil || quickOrder.applePayToken != nil
        if !isAddressExists {
            self.showAddressPicker(vc)
        } else if !isPaymentCardExists && ApplePayCard.isApplePayAvailable() {
            self.showApplePayPayment(vc)
        } else if !isPaymentCardExists {
            self.showPaymentCardPicker(vc)
        } else {
            guard let deliveryOption = DataProvider.sharedInstance.deliveryPricing.value.filter({ $0.isAvailable }).last else { return }
            quickOrder.delivery.deliveryRequestDate = deliveryOption.deliveryDateForDate(Date())
            quickOrder.delivery.deliverySurchargeID = deliveryOption.type.rawValue
            quickOrder.delivery.deliveryUpchargeAmount = deliveryOption.amount
            quickOrder.orderPlaced = Date()
            quickOrderCreated.next()
        }
    }
    
    fileprivate func showApplePayPayment<T: PKPaymentAuthorizationViewControllerDelegate>(_ vc: T) where T: UIViewController {
        let viewController = PKPaymentAuthorizationViewController(paymentRequest: PKPaymentRequest.lemonPaymentRequest)
        viewController?.delegate = vc
        vc.present(viewController!, animated: true, completion: nil)
    }
    
    
    func tokenizeApplePay(_ payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        if let token = DataProvider.sharedInstance.paymentToken,
            let braintreeClient = BTAPIClient(authorization: token) {
            let client = BTApplePayClient(apiClient: braintreeClient)
            client.tokenizeApplePay(payment) { [weak self] nonce, error in
                if let error = error {
                    print("error apple pay: \(error.localizedDescription)")
                    completion(.failure)
                } else {
                    print("succeseed apple pay")
                    self?.quickOrder.value?.applePayToken = nonce?.nonce
                    completion(.success)
                }
            }
        }
    }
    
    fileprivate func showAddressPicker<T: PKPaymentAuthorizationViewControllerDelegate>(_ vc: T) where T: UIViewController {
        guard let userWrapper = DataProvider.sharedInstance.userWrapper else { return }
        let addressList: [OptionItemProtocol] = userWrapper.activeAddresses.map { $0 }
        let addressPicker = OptionPicker(optionItemList: addressList, optionsType: .addresses) { [weak self, weak vc] in
            if let selectedOption = $0 {
                switch selectedOption {
                case .chose(let address):
                    if let address = address as? Address,
                        let vc = vc,
                        let order = self?.quickOrder.value {
                        order.delivery.pickupAddress = address
                        order.delivery.dropoffAddress = address
                        self?.createQuickOrder(vc)
                    } else {
                        self?.quickOrderCanceled.next()
                    }
                    break
                case .new:
                    self?.newAddressAction? { [weak self, weak vc] address in
                        if let vc = vc,
                            let order = self?.quickOrder.value {
                            order.delivery.pickupAddress = address
                            order.delivery.dropoffAddress = address
                            self?.createQuickOrder(vc)
                        } else {
                            self?.quickOrderCanceled.next()
                        }
                    }
                    break
                }
            } else {
                self?.quickOrderCanceled.next()
            }
        }
        vc.present(addressPicker, animated: true, completion: nil)
    }
    
    fileprivate func showPaymentCardPicker<T: PKPaymentAuthorizationViewControllerDelegate>(_ vc: T) where T: UIViewController {
        guard let userWrapper = DataProvider.sharedInstance.userWrapper else { return }
        //swift native bug!!! without map() getting crash
        let paymentCardList: [OptionItemProtocol] = userWrapper.activePaymentCards.map { $0 }
        let paymentCardPicker = OptionPicker(optionItemList: paymentCardList, optionsType: .paymentCards) { [weak self, weak vc] in
            if let selectedOption = $0 {
                switch selectedOption {
                case .chose(let paymentCard):
                    if let paymentCard = paymentCard as? PaymentCard,
                        let vc = vc {
                        self?.quickOrder.value?.card = paymentCard
                        self?.createQuickOrder(vc)
                    } else {
                        self?.quickOrderCanceled.next()
                    }
                    break
                case .new:
                    self?.newPaymentCardAction? { paymentCard in
                        self?.quickOrder.value?.card = paymentCard
                        if let vc = vc {
                            self?.createQuickOrder(vc)
                        }
                    }
                }
            } else {
                self?.quickOrderCanceled.next()
            }
        }
        vc.present(paymentCardPicker, animated: true, completion: nil)
    }
}

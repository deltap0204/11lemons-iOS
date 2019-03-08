//
//  DeliveryViewModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond
import UIKit
import Bolts
import ReactiveKit


final class DeliveryViewModel {
    
    var timeConstraint = Observable("23h 48m")
    
    var selectedDeliveryOption = Observable<DeliveryPricing?>(nil)
    
    var notes = Observable<String?>("")
    var paymentOption = Observable<Option?>(nil)
    var photos = MutableObservableArray<OrderPhoto>([OrderPhoto]())
    var initialPhotos: [OrderPhoto] = []
    var applePayToken = Observable<String?>(nil)
    
    var address = Observable<Address?>(nil)
    
    var promocode = Observable<String?>(nil)
    fileprivate var promocodeId = Observable<Int?>(nil)
    
    let newPaymentViewModel: CommonContainerViewModel?
    let newAddressViewModel: CommonContainerViewModel?
    let walletViewModel: Observable<UserViewModel?> = Observable(nil)
    
    let editMode: Bool
    let defaultApplePay: String?
    
    let hasChanges = Observable(false)
    
    
    let completeButtonTitleChanged = Observable<String?>(nil)
    
    let userWalletBalance: Observable<Double?> = Observable(0)
    
    let pickupETA: Observable<Int> = Observable(Config.StandardPickupETA)
    

    fileprivate(set) lazy var shouldHideNotesHint: SafeSignal<Bool> = {
        return self.notes.map { !($0?.isEmpty ?? true) }
    }()
    
    var checkAddressRequest: Action<() throws -> [LocationData]> {
        return Action { [weak self] in
            return Signal { sink in
                if let zip = self?.order.delivery.pickupAddress?.zip {
                    _ = LemonAPI.validateZip(zip: zip).request().observeNext { (resolver: @escaping EventResolver<[LocationData]>) in
                        sink.completed(with:  { return try resolver() } )
                    }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    var order: Order
    fileprivate let preferences: Preferences
    
    init(order: Order, editMode: Bool) {
        if let userWrapper = DataProvider.sharedInstance.userWrapper {
            preferences = userWrapper.changedUser.preferences
            newPaymentViewModel = CommonContainerViewModel(userWrapper: userWrapper, screenIndetifier: .PaymentCardScreen, backButtonTitle: "Order")
            newAddressViewModel = CommonContainerViewModel(userWrapper: userWrapper, screenIndetifier: .AddressScreen, backButtonTitle: "Order")
        } else {
            preferences = Preferences()
            newPaymentViewModel = nil
            newAddressViewModel = nil
        }
        self.editMode = editMode
        
        self.order = order
        self.order.notes = editMode ? order.notes : preferences.notes
        self.defaultApplePay = (order.applePayToken?.isEmpty ?? true) ? nil : order.applePayToken
        self.applePayToken.next(defaultApplePay)
        
        address.next(order.delivery.pickupAddress)
        newAddressViewModel?.result.observeNext { result in
            if let address = result as? Address {
                self.address.next(address)
                order.delivery.pickupAddress = address
                order.delivery.dropoffAddress = address
            }
        }
        
        // default payment is available
        if let card = order.card, editMode && !card.deleted {
            paymentOption.value = Option.chose(item: card)
        } else if let card = DataProvider.sharedInstance.userWrapper?.defaultPaymentCard.value as? PaymentCard {
            paymentOption.value = Option.chose(item: card)
            self.order.card = card
        } else if let applePayCard = DataProvider.sharedInstance.userWrapper?.applePayCard {
            paymentOption.value = Option.chose(item: applePayCard)
            self.order.card = nil
        }
        newPaymentViewModel?.result.observeNext { result in
            if let card = result as? PaymentCard {
                self.paymentOption.value = Option.chose(item: card)
                self.order.card = card
            }
        }
        
        paymentOption.skip(first: 1).observeNext { option in
            if let option = option {
                switch option {
                case Option.chose(let card):
                    if let card  = card as? PaymentCard {
                        order.card = card
                    }
                default: ()
                }
            }
        }
        
        applePayToken.skip(first: 1).observeNext { token in
            order.applePayToken = token
            order.card = nil
        }
        
        promocodeId.skip(first: 1).observeNext { id in
            order.promoId = id
        }
        
        notes.next(order.notes)
        notes.skip(first: 1).observeNext { [weak self] notes in self?.order.notes = notes ?? ""; self?.hasChanges.value = self?.order.hasChanges ?? false }
        
        timeConstraint.value = deliveryTimeConstraintForDate(order.orderPlaced ?? Date())
        
        if let deliverySurchargeID = order.delivery.deliverySurchargeID,
            let deliveryType = DeliveryOption(rawValue: deliverySurchargeID),
            let amount = order.delivery.deliveryUpchargeAmount, editMode {
            selectedDeliveryOption.next(DeliveryPricing(type: deliveryType, amount: amount))
        } else if let defaultOption = DataProvider.sharedInstance.deliveryPricing.value.filter({ $0.isAvailable }).last {
            selectedDeliveryOption.next(defaultOption)
        }
        
        DataProvider.sharedInstance.userWrapperObserver.observeNext { [weak self] in
            if let userWrapper = $0 {
                self?.walletViewModel.value = UserViewModel(userWrapper:userWrapper)
                self?.userWalletBalance.next(userWrapper.walletAmount.value)
            } else {
                self?.walletViewModel.value = nil
            }
        }
        
        order.orderImages?.forEach {
            let imgId = $0.id
            _ = LemonAPI.getOrderImage(imgURL: $0.imageURL).request().observeNext { [weak self] (resolver: ImageResolver) in
                if let image = resolver {
                    self?.photos.append(OrderPhoto(orderId: self?.order.id ?? 0, orderPicId: imgId, photo: image))
                    self?.initialPhotos.append(OrderPhoto(orderId: self?.order.id ?? 0, orderPicId: imgId, photo: image))
                }
            }
            
        }
    }
    
    
    func refresh() {
        if let card = DataProvider.sharedInstance.userWrapper?.defaultPaymentCard.value as? PaymentCard {
            if self.order.card == nil {
                self.paymentOption.value = Option.chose(item: card)
                self.order.card = card
            }
        }
    }
    
    
    var sendOrder: Action<() throws -> Order?> {
        return Action { [weak self] in
            Signal { [weak self] sink in
                guard let order = self?.order, let strongSelf = self else { return /*nil */ BlockDisposable {}}
                if !strongSelf.editMode {
                    order.orderPlaced = Date()
                }
                if let deliveryOption = strongSelf.selectedDeliveryOption.value {
                    if !strongSelf.editMode {
                        order.delivery.deliveryRequestDate = deliveryOption.deliveryDateForDate(Date())
                    }
                    order.delivery.deliverySurchargeID = deliveryOption.type.rawValue
                    order.delivery.deliveryUpchargeAmount = deliveryOption.amount
                }
                
                strongSelf.createOrderAsync(order).continueWith { (task: BFTask!) -> BFTask<AnyObject> in
                        if let order = task.result as? Order {
                            let photos = strongSelf.photos.array
                            // Create a trivial completed task as a base case.
                            var task = BFTask<AnyObject>(result:nil)
                            for photo in photos {
                                if (strongSelf.initialPhotos.filter { $0.photo == photo.photo}).count <= 0 {
                                    // For each item, extend the task with a function to upload photo.
                                    task = task.continueWith { (task: BFTask!) -> BFTask<AnyObject> in
                                        return strongSelf.uploadPhotoAsync(photo.photo, order: order)
                                    }
                                }
                            }
                        }
                        return task
                    }.continueWith { (task: BFTask!) -> AnyObject! in
                        // all photos where uploaded
                        if let error = task.error {
                            sink.completed(with:  {throw error })
                        } else {
                            sink.completed(with:  {return task.result as? Order })
                        }
                        
                        return nil
                    }
                
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    var validatePromocode: Action<() throws -> Bool> {
        return Action { [weak self] in
            return Signal { sink in
                if let promocode = self?.promocode.value {
                    _ = LemonAPI.validatePromocode(code: promocode).request().observeNext { (resolver: EventResolver<String>) in
                        do {
                            if let promoId = Int(try resolver()) {
                                self?.promocodeId.next(promoId)
                                sink.completed(with: { true })
                            } else {
                                self?.promocodeId.next(nil)
                                sink.completed(with: { false })
                            }
                        } catch let error {
                            sink.completed(with:  { throw error } )
                        }
                    }
                    //return nil
                    return BlockDisposable {}
                } else {
                    sink.completed(with:  {return false })
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    func createOrderAsync(_ order: Order) -> BFTask<AnyObject> {
        let task = BFTaskCompletionSource<AnyObject>()

        if editMode {
            _ = LemonAPI.editOrder(editedOrder: order).request().observeNext { [weak self] (result: EventResolver<Order>) in
                self?.onRequestComplete(result, task: task)
            }
        } else {
            _ = LemonAPI.addOrder(order: order).request().observeNext { [weak self] (result: EventResolver<Order>) in
                self?.onRequestComplete(result, task: task)
            }
        }
        
        return task.task
    }
    
    func onRequestComplete(_ result: EventResolver<Order>, task: BFTaskCompletionSource<AnyObject>) {
        do {
            let order = try result()
// replace SaveData COMPLETE
            //            if !editMode {
//                LemonCoreDataManager.insert(objects: order.dataModel)
//            }
//            order.syncDataModel()
            DataProvider.sharedInstance.refreshAdminOrdersFromBackend()
            self.order.updated.next(true)
            task.set(result: order)
        } catch let error as BackendError {
            task.set(error: NSError(domain: "11lemons", code: 0, userInfo: [NSLocalizedDescriptionKey : error.message]))
        } catch _ {
            task.set(error: (NSError(domain: "11lemons", code: 0, userInfo: [NSLocalizedDescriptionKey : "Error in receiving order id of the newly created order"])))
        }
    }
    
    func uploadPhotoAsync(_ photo: UIImage, order: Order) -> BFTask<AnyObject> {
        let task = BFTaskCompletionSource<AnyObject>()
        ImageCache.saveImage(photo, url: "profile_photo").observeNext {
            if let fileURL = $0() {
                _ = LemonAPI.uploadPhotoNote(photoUrl: fileURL, forOrder: order)
                    .request().observeNext { (resultResolver: EventResolver<String>) in
                        do {
                            task.set(result: try resultResolver() as AnyObject)
                        } catch let error as BackendError {
                            task.set(error: NSError(domain: "11lemons", code: 0, userInfo: [NSLocalizedDescriptionKey : error.message]))
                        } catch _ {}
                }
            }
        }
        return task.task
    }
    
    func syncUpdates(_ completion: (() -> Void)?) {
        _ = LemonAPI.editOrder(editedOrder: order).request().observeNext { [weak self] (result: EventResolver<Order>) in
// replace SaveData COMPLETE
            //            self?.order.syncDataModel()
            DataProvider.sharedInstance.refreshAdminOrdersFromBackend()
            self?.hasChanges.value = false
            
            completion?()
        }
    }
}

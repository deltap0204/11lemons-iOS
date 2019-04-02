//
//  DetailedNewOrderViewModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond


final class DetailedNewOrderViewModel {
    
    var detergents = [Detergent.Original, Detergent.MountainSpring, Detergent.Lavender, Detergent.FreeNGentle]//should have same order as corresponding buttons on UI
    var selectedDetergent = Observable(Detergent.Original)
    
    var shirts = [Shirt.Folded, Shirt.Hanger]//should have same order as corresponding buttons on
    let selectedShirt = Observable(Shirt.Hanger)
    
    var washFoldSelected = Observable(false)
    var launderPressSelected = Observable(false)
    var dryCleanSelected = Observable(false)
    
    let tipsValues = ["0%", "5%", "10%", "15%", "20%", "25%"]
    var selectedTips = Observable<Int>(0)
    
    var softeners = [Softener.None, Softener.Downy]//should have same order as corresponding buttons on
    var selectedSoftener = Observable(Softener.Downy)
    
    var dryers = [Dryer.None, Dryer.Bounce]//should have same order as corresponding buttons on
    var selectedDryer = Observable(Dryer.Bounce)
    
    var deliveryViewModel: DeliveryViewModel {
        return DeliveryViewModel(order: order, editMode: editMode)
    }
    let commonContainerViewModel: CommonContainerViewModel?

    let walletViewModel: Observable<UserViewModel?> = Observable(nil)
    
    let userWalletBalance: Observable<Double?> = Observable(0)
    
    let pickupETA: Observable<Int> = Observable(Config.StandardPickupETA)
        
    var order: Order
    fileprivate let preferences: Preferences
    
    let editMode: Bool
    let hasChanges = Observable(false)
    
    init(editedOrder: Order? = nil) {
        editMode = editedOrder != nil
        if let userWrapper = DataProvider.sharedInstance.userWrapper {
            self.commonContainerViewModel = CommonContainerViewModel(userWrapper: userWrapper, screenIndetifier: .AddressScreen)
            self.preferences = userWrapper.changedUser.preferences
        } else {
            self.commonContainerViewModel = nil
            self.preferences = Preferences()
        }
        
        let defaultOrder = DataProvider.sharedInstance.defaultOrder
        defaultOrder.shirt = self.preferences.shirts
        defaultOrder.detergent = self.preferences.detergent
        defaultOrder.softener = self.preferences.softener
        defaultOrder.dryer = self.preferences.dryer
        defaultOrder.tips = self.preferences.tips
        defaultOrder.serviceType = []
        self.order = editedOrder ?? defaultOrder        
        
        self.selectedShirt.next(order.shirt)
        self.selectedDetergent.next(order.detergent)
        
        selectedShirt.skip(first: 1).observeNext { [weak self] shirt in self?.order.shirt = shirt; self?.hasChanges.value = self?.order.hasChanges ?? false }
        selectedDetergent.skip(first: 1).observeNext { [weak self] detergent in self?.order.detergent = detergent; self?.hasChanges.value = self?.order.hasChanges ?? false }
        
        selectedSoftener.next(order.softener)
        selectedSoftener.skip(first: 1).observeNext { [weak self] softener in self?.order.softener = softener; self?.hasChanges.value = self?.order.hasChanges ?? false }
        
        selectedDryer.next(order.dryer)
        selectedDryer.skip(first: 1).observeNext { [weak self] dryer in self?.order.dryer = dryer; self?.hasChanges.value = self?.order.hasChanges ?? false }
        
        selectedTips.next(order.tips)
        selectedTips.skip(first: 1).observeNext { [weak self] tips in self?.order.tips = tips; self?.hasChanges.value = self?.order.hasChanges ?? false }
        
        washFoldSelected.next(order.serviceType.contains(.WashFold))
        
        washFoldSelected.observeNext { [weak self] selected in
            if self!.order.serviceType.contains(.WashFold) && !selected {
                if let index = self?.order.serviceType.index(of: .WashFold) {
                    self?.order.serviceType.remove(at: index)
                }
            } else {
                if !self!.order.serviceType.contains(.WashFold) && selected {
                    self?.order.serviceType.append(.WashFold)
                }
            }
            self?.hasChanges.value = self?.order.hasChanges ?? false
        }
        
        dryCleanSelected.next(order.serviceType.contains(.DryClean))
        
        dryCleanSelected.observeNext { [weak self] selected in
            if self!.order.serviceType.contains(.DryClean) && !selected {
                if let index = self?.order.serviceType.index(of: .DryClean) {
                    self?.order.serviceType.remove(at: index)
                }
            } else {
                if !self!.order.serviceType.contains(.DryClean) && selected {
                    self?.order.serviceType.append(.DryClean)
                }
            }
            self?.hasChanges.value = self?.order.hasChanges ?? false
        }
        
        launderPressSelected.next(order.serviceType.contains(.LaunderPress))
        
        launderPressSelected.observeNext { [weak self] selected in
            if self!.order.serviceType.contains(.LaunderPress) && !selected {
                if let index = self?.order.serviceType.index(of: .LaunderPress) {
                    self?.order.serviceType.remove(at: index)
                }
            } else {
                if !self!.order.serviceType.contains(.LaunderPress) && selected {
                    self?.order.serviceType.append(.LaunderPress)
                }
            }
            self?.hasChanges.value = self?.order.hasChanges ?? false
        }
        
        DataProvider.sharedInstance.userWrapperObserver.observeNext { [weak self] in
            if let userWrapper = $0 {
                self?.walletViewModel.value = UserViewModel(userWrapper:userWrapper)
                self?.userWalletBalance.next(userWrapper.walletAmount.value)
            } else {
                self?.walletViewModel.value = nil
            }
        }
    }
    
    func anyServiceTypeSelected() -> Bool {
        return self.washFoldSelected.value || self.dryCleanSelected.value || self.launderPressSelected.value
    }
    
    func refresh() {
        
        if let userWrapper = DataProvider.sharedInstance.userWrapper {
            if order.delivery.pickupAddress == nil {
                order.delivery.pickupAddress = userWrapper.defaultAddress.value
                order.delivery.dropoffAddress = userWrapper.defaultAddress.value
            }
        }
    }
    
    func resetOrder() {
        if editMode {
            self.order.reset()
        }
    }
    
    func syncUpdates(_ completion: (() -> Void)?) {
        _ = LemonAPI.editOrder(editedOrder: order).request().observeNext { [weak self] (result: EventResolver<Order>) in
            DataProvider.sharedInstance.refreshUserOrders()
            self?.hasChanges.value = false
            completion?()
        }
    }
}

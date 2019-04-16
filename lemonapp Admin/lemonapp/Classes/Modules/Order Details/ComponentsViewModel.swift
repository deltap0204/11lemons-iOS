//
//  ComponentsViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/12/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

class ComponentsViewModel {
    var order: Order
    var changedUser: User?
    weak var delegate: ComponentsViewModelDelegate?
    
    init(order: Order, delegate: ComponentsViewModelDelegate) {
        self.delegate = delegate
        self.order = order
        self.changedUser = order.createdBy
    }
    
    func addNote(_ text: String) {
        order.notes = text
        updateOrder()
    }
    
    func resetServicesToOrderDetail() {
        delegate?.resetServicesToOrderDetail()
    }
    
    func resetAttributesToOrderDetail() {
        delegate?.resetAttributesToOrderDetail()
    }
    
    func updateOrder() {
        _ = LemonAPI.updateOrder(order: order, orderID: order.id).request().observeNext { [weak self] (result: EventResolver<Order>) in
            guard let strongSelf = self else { return }
            do {
                let newOrder = try result()
                strongSelf.delegate?.setupOrder(newOrder)
            } catch { }
        }
    }
    
    func getPreferencesVM() -> PreferencesRowViewModel {
        let rowsVM = getPreferencesOptions()
        let vm = PreferencesRowViewModel(rowViewModels: rowsVM)
        return vm
    }
    
    func getPreferencesOptions() -> [PreferenceRowUser] {
        fatalError("Must Override")
    }
}

extension ComponentsViewModel: PreferenceRowViewModelDelegate {
    func setupOrder(_ order: Order) {
        delegate?.setupOrder(order)
    }
    
    func changeOrderDetailToAdd(_ order: Order) {
        delegate?.changeOrderDetailToAdd(order)
    }
    
    func showModal(_ alert: UIAlertController) {
        delegate?.showModal(alert)
    }
}

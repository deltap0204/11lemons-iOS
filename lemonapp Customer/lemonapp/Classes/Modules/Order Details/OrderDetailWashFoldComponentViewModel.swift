//
//  OrderDetailWashFoldComponentViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/12/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

class OrderDetailWashFoldComponentViewModel: ComponentsViewModel {
    
    func setTypeOfServiceWashFoldToOrderDetail(_ position: Int, isSelected: Bool) {
        delegate?.setTypeOfServiceWashFoldToOrderDetail(position, isSelected: isSelected)
    }
    
    func changeLbs(_ lbs: Double) {
        delegate?.changeLbs(lbs)
    }
    
    func getCurrentLbs() -> Double? {
        return delegate?.getCurrentLbs()
    }

    override func getPreferencesOptions() -> [PreferenceRowUser] {
        let detergentRow = DetergentPreferenceRowViewModel(order: order, delegate: self)
        let softnerRow = SoftnerPreferenceRowViewModel(order: order, delegate: self)
        let Dryer = DryPreferenceRowViewModel(order: order, delegate: self)
        
        return [detergentRow, softnerRow, Dryer]
    }
}

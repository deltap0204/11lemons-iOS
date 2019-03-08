//
//  OrderDetailMenShirtComponentViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/12/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

class OrderDetailMenShirtComponentViewModel: ComponentsViewModel {
    
    var attributes: [Category] = []
    
    override init(order: Order, delegate: ComponentsViewModelDelegate) {
        super.init(order: order, delegate: delegate)
        getAttributes()
    }
        
    func setTypeOfServiceToOrderDetail(_ position: Int, isSelected: Bool) {
        delegate?.setTypeOfServiceToOrderDetail(position, isSelected: isSelected)
    }
    
    func setupAttributesToOrderDetail(_ category: Category, attributes: [Attribute]) {
        delegate?.setupAttributesToOrderDetail(category, attributes: attributes)
    }
    
    override func getPreferencesOptions() -> [PreferenceRowUser] {
        let packagingRow = PackagingPreferenceRowViewModel(order: order, delegate: self)
        let starchRow = StarchPreferenceRowViewModel(order: order, delegate: self)
        
        return [packagingRow, starchRow]
    }
    
    //MARK:- attribute
    func getAttributes(completion: (() -> ())? = nil) {
        _ = LemonAPI.getAttributeCategories().request().observeNext { [weak self](result: EventResolver<[Category]>) in
            guard let strongSelf = self else { return }
            do {
                let categories = try result()
                strongSelf.attributes = categories.filter { $0.active && !$0.deleted}
                completion?()
            } catch {
                completion?()
            }
        }
    }
    
    func getAttributeCategoryBy(_ id: Int) -> Category? {
        let attCategories = attributes.filter {$0.id == id}.map{ $0.copy() }
        if attCategories.count > 0 {
            let category = attCategories[0]
            category.attributes?.forEach{ $0.isSelected = false }
            return category
        }
        return nil
    }
}

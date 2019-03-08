//
//  PricingViewModel.swift
//  lemonapp
//
//  Created by Svetlana Dedunovich on 5/23/16.
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond


final class PricingViewModel: ViewModel {
    
    let productCellViewModels = MutableObservableArray<ProductCellViewModel>()
    
    init() {
        update({})
    }

    func update(_ completion: @escaping () -> Void) {
        _ = LemonAPI.getDepartmentsAll().request().observeNext { [weak self] (result: EventResolver<[Service]>) in
            do {
                guard let strongSelf = self else { return }
                completion()
                let departments = try result()
                
                strongSelf.refreshDepartmentList( departments.filter{$0.active} )
                completion()
                
            } catch { }
        }
    }
    
    fileprivate func refreshDepartmentList(_ departments: [Service]) {
        self.productCellViewModels.replace(with: departments.flatMap { $0.active ? ProductCellViewModel(department: $0) : nil })
    }
}

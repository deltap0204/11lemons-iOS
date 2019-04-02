//
//  PricingViewModel.swift
//  lemonapp
//
//  Created by Svetlana Dedunovich on 5/23/16.
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit

protocol ProductViewModelDelegate {
    func hiddenLoading()
}

final class PricingViewModel: ViewModel {
    
    let departments: MutableObservableArray<Service>
    let productCellViewModels = MutableObservableArray<ProductCellViewModel>()
    var disposeBag = DisposeBag()
    var delegate: ProductViewModelDelegate?

    init() {
        self.departments = DataProvider.sharedInstance.productsItems
        departments.observeNext { [weak self] event in
            guard let self = self else {return}
            self.refreshDepartmentList(self.departments.array)
            }.dispose(in: disposeBag)
        self.updateDepartmentList({})
    }

    func updateDepartmentList(_ completion: @escaping () -> Void) {
        DataProvider.sharedInstance.refreshDepartments(completion)
    }
    
    fileprivate func refreshDepartmentList(_ departments: [Service]) {
        self.productCellViewModels.replace(with: departments.compactMap { $0.active ? ProductCellViewModel(department: $0) : nil })
        self.delegate?.hiddenLoading()
    }
}

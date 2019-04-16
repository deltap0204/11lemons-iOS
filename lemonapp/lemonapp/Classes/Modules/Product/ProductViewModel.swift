//
//  ProductViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/4/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond

protocol ProductViewModelDelegate {
    func navigateToProductDetail(_ serviceCategory: Service)
}

final class ProductViewModel: ViewModel {
    
    let productCellViewModels = MutableObservableArray<ProductAdminCellViewModel>()
    var productCellViewModelsBackup: [Bool] = []
    var isEditionMode: Observable<Bool> = Observable(false)
    var delegate: ProductViewModelDelegate?
    
    init() {
        self.updateDepartmentList({})

        isEditionMode.observeNext { [weak self] isEditionMode in
            self?.productCellViewModels.array.forEach {vm in
                vm.isEditionMode.value = isEditionMode
            }
        }
    }
    
    func updateDepartmentList(_ completion: @escaping () -> Void) {
        _ = LemonAPI.getDepartmentsAll().request().observeNext { [weak self] (result: EventResolver<[Service]>) in
            do {
                completion()
                let departments = try result()
                self?.refreshDepartmentList(departments)
            } catch { }
        }
    }
    
    func onEdit() {
        isEditionMode.value = !isEditionMode.value
    }
    
    func saveList() {
        productCellViewModelsBackup =  []
        productCellViewModels.array.forEach {
            productCellViewModelsBackup.append($0.isActive.value)
        }
    }
    
    func updateChanges() {
        let productCellViewModelsArray = self.productCellViewModels.array.sorted { $0.isActive.value && !$1.isActive.value }
        self.productCellViewModels.replace(with: productCellViewModelsArray)
        self.productCellViewModels.array.forEach{ viewModel in
            if viewModel.hasChanged {
                _ = LemonAPI.updateServices(service: viewModel.service).request().observeNext { (_: EventResolver<String>) in
                }
            }
            viewModel.hasChanged = false
        }
    }
    
    func restoreList() {
        var position = 0
        productCellViewModelsBackup.forEach {
            productCellViewModels.array[position].isActive.value = $0
            productCellViewModels.array[position].hasChanged = false
            position += 1
        }
    }
    
    func editProduct(_ service: Service) {
        self.delegate?.navigateToProductDetail(service)
    }
    
    fileprivate func refreshDepartmentList(_ newDepartments: [Service]) {
        DispatchQueue.main.async {
            let newDepartmentsOrder = newDepartments.sorted { $0.active && !$1.active }
            let productCellViewModelsArray = newDepartmentsOrder.flatMap {ProductAdminCellViewModel(service: $0, holdAndEdit: { service in
                self.editProduct(service)
            }) }
            self.productCellViewModels.replace(with: productCellViewModelsArray)
        }
    }
}

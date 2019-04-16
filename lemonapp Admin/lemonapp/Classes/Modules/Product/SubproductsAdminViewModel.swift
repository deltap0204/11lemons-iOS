//
//  SubproductsAdminViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/31/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond

protocol SubproductViewModelDelegate {
    func navigateToProductDetail(_ service: Service, department: Service)
    func goBackSuccefully()
}

final class SubproductsAdminViewModel: ViewModel {
    
    let subproductCellViewModels = MutableObservableArray<SubproductAdminCellViewModel>()
    let title: String
    let department: Service
    var delegate: SubproductViewModelDelegate?
    let isBusy = Observable<Bool>(false)
    
    init(department: Service) {
        self.department = department
        self.title = department.name
        refreshServiceCell(department.typesOfService)
    }
    
    func getServiceByPosition(_ position: Int) -> Service {
        return subproductCellViewModels.array[position].service
    }
    
    func updateServices() {
        _ = LemonAPI.getAllServices().request().observeNext { [weak self] (result: EventResolver<[Service]>) in
            do {
                let services = try result()
                self?.refreshServiceCell(services.filter { $0.parentID == self!.department.id } )
            } catch { }
        }
    }
    
    func editProduct(_ service: Service) {
        self.delegate?.navigateToProductDetail(service, department: department)
    }
    
    func deleteService(_ service: Service) {
        isBusy.value = true
        _ = LemonAPI.deleteService(serviceID: service.id).request().observeNext { [weak self] (_: EventResolver<String>) in
            guard let strongSelf = self else { return }
            strongSelf.updateServices()
            strongSelf.isBusy.value = false
            strongSelf.delegate?.goBackSuccefully()
        }
    }
    
    fileprivate func refreshServiceCell(_ newServices: [Service]?) {
        let newServicesOrder = newServices != nil ? newServices!.sorted{ $0.active && !$1.active }  : []
        self.subproductCellViewModels.replace(with: newServicesOrder.flatMap { SubproductAdminCellViewModel(service: $0, holdAndEdit: { service in
            self.editProduct(service)
        }) })
    }
}

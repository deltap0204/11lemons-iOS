//
//  ServiceSelectionViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/31/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond

final class ServiceSelectionViewModel {
    
    let subproductCellViewModels = MutableObservableArray<ServiceSelectionCellViewModel>()
    let title: String
    let department: Service
    
    weak var selectionDelegate: ServiceSelectionDelegate?
    
    init(department: Service, selectionDelegate: ServiceSelectionDelegate) {
        self.department = department
        self.selectionDelegate = selectionDelegate
        self.title = department.name
        refreshServiceCell(department.typesOfService)
    }
    
    func getServiceByPosition(_ position: Int) -> Service {
        return subproductCellViewModels.array[position].service
    }
    
    func selectedService(_ position: Int) {
        guard position < subproductCellViewModels.count else { return }
        subproductCellViewModels.array[position].isSelected.value = !subproductCellViewModels.array[position].isSelected.value
    }
    
    func submitChanges() {
        selectionDelegate?.finalSelection(department, services: subproductCellViewModels.array.map{$0.service})
    }
    
    fileprivate func refreshServiceCell(_ newServices: [Service]?) {
        guard let services = newServices else { return }
        self.subproductCellViewModels.replace(with: services.sorted { $0.active && !$1.active }.flatMap { ServiceSelectionCellViewModel(service: $0) })
    }
}

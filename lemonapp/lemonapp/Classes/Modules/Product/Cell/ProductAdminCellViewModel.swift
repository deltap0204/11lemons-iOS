//
//  ProductAdminCellViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/4/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond

final class ProductAdminCellViewModel: ViewModel {
    
    let title: String
    let details: String
    let image: UIImage?
    let isAccessoryViewHidden: Bool
    let subprodutsViewModel: SubproductsAdminViewModel?
    var isEditionMode: Observable<Bool> = Observable(false)
    var isActive = Observable(false)
    var hasChanged: Bool
    
    let service: Service
    var onHoldAndEdit: ((_ service: Service) -> ())?
    
    init (service: Service, holdAndEdit: ((_ service: Service) -> ())?) {
        self.onHoldAndEdit = holdAndEdit
        self.service = service
        self.title = service.name
        self.details = service.description
        self.image = ProductHelper.getImageBy(service.id)
        self.isAccessoryViewHidden = false
        self.hasChanged = false
        
        self.isActive.value = service.active
        if !service.active {
            self.isActive.value = false
        }
        
        self.subprodutsViewModel = SubproductsAdminViewModel(department: service)
        self.isActive.observeNext { [weak self] isActive in
            self?.service.active = isActive
            self?.hasChanged = true
        }
    }
    
    func editService() {
        if !isEditionMode.value {
            self.onHoldAndEdit?(self.service)
        }
    }
}

//
//  SubproductAdminCell.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/31/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond

final class SubproductAdminCellViewModel: ViewModel {
    
    let title: String
    let price: Double
    var isActive = Observable(false)
    
    let service: Service
    var onHoldAndEdit: ((_ service: Service) -> ())?
    
    init(service: Service, holdAndEdit: ((_ service: Service) -> ())?) {
        self.onHoldAndEdit = holdAndEdit
        self.service = service
        self.price = service.price
        self.title = service.name
        self.isActive.value = service.active
        if !service.active {
            self.isActive.value = false
        }
    }
    
    func editProduct() {
        self.onHoldAndEdit?(self.service)
    }
}



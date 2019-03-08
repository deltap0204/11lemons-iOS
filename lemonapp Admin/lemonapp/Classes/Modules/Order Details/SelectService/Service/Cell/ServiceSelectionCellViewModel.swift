//
//  ServiceSelectionCellViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/31/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond

final class ServiceSelectionCellViewModel: ViewModel {
    
    let title: String
    let price: Double
    let selectStatusImage = Observable<UIImage?>(UIImage(named: "circleEmpty"))
    var isSelected = Observable<Bool>(false)
    let isActive: Bool
    
    let service: Service
    
    init(service: Service) {
        self.service = service
        self.price = service.price
        self.title = service.name
        self.isSelected.value = service.isSelected
        self.isActive = service.active
        self.isSelected.observeNext { [weak self] isSelected in
            guard let strongSelf = self else { return }
            let imageName = isSelected ? "circleChecked" : "circleEmpty"
            strongSelf.selectStatusImage.value = UIImage(named: imageName)
            strongSelf.service.isSelected = isSelected
        }
    }
}



//
//  DepartmentSelectionCellModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/4/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond

final class DepartmentSelectionCellModel {
    
    let department: Service
    let title: String
    let details: String
    let image: UIImage?
    let numberOfServicesSelected = Observable<Int>(0)
    let selectStatusImage = Observable<UIImage?>(UIImage(named: "circleEmpty"))
    let isActive: Bool
    
    init(department: Service) {
        self.department = department
        self.title = department.name
        self.details = department.description
        self.image = ProductHelper.getImageBy(department.id)
        self.isActive = department.active
        numberOfServicesSelected.observeNext{ [weak self] number in
            guard let strongSelf = self else { return }
            strongSelf.setupImageSelectStatus(number)
        }
    }
    
    func changeSelection() {
        if numberOfServicesSelected.value > 0 {
            clear()
        } else {
            selectAll()
        }
    }
    
    func clear() {
        department.typesOfService?.forEach {
            $0.isSelected = false
        }
        numberOfServicesSelected.value = 0
    }
    
    func selectAll() {
        department.typesOfService?.forEach {
            $0.isSelected = true
        }
        numberOfServicesSelected.value = department.typesOfService!.count
    }
    
    func setupImageSelectStatus(_ number: Int) {
        if number == 0 {
            selectStatusImage.value = UIImage(named: "circleEmpty")
        } else {
            if number == department.typesOfService!.count {
                selectStatusImage.value = UIImage(named: "circleChecked")
            } else {
                selectStatusImage.value = UIImage(named: "circleFilled")
            }
        }
    }
}

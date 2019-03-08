//
//  ServiceCategory.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation

class ServiceCategory {
    var name: String
    var description: String
    var isActive: Bool
    var isTaxable: Bool
    var taxRate: Double
    var price: Double
    
    init(name: String, description: String, isActive: Bool, isTaxable: Bool, taxRate: Double = 0.0, price: Double = 0.0) {
        self.name = name
        self.description = description
        self.isActive = isActive
        self.isTaxable = isTaxable
        self.taxRate = taxRate
        self.price = price
    }
    
    convenience init() {
        self.init(name: "Name", description: "Description", isActive: false, isTaxable: false)
    }
}

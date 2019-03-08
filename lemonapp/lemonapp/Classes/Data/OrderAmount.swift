//
//  OrderAmount.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation

final class OrderAmount {
    var amount = 0.0
    var tax = 0.0
    var amountWithoutTax = 0.0
    var numberOfItems = 0
    var state = ""
    
    init() {}
    
    init(amount: Double, tax: Double, amountWithoutTax: Double, numberOfItems: Int, state: String) {
        self.amount = amount
        self.tax = tax
        self.amountWithoutTax = amountWithoutTax
        self.numberOfItems = numberOfItems
        self.state = state
    }
}
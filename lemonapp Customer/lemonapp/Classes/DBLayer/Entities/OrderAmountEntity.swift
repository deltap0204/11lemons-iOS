//
//  OrderAmountEntity.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//


import Foundation
import RealmSwift
public class OrderAmountEntity: Object {
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var tax: Double = 0.0
    @objc dynamic var amountWithoutTax: Double = 0.0
    @objc dynamic var numberOfItems = 0
    @objc dynamic var state = ""
    
    static func create(with orderAmount: OrderAmount) -> OrderAmountEntity {
        let orderAmountEntity = OrderAmountEntity()
        orderAmountEntity.amount = orderAmount.amount
        orderAmountEntity.tax = orderAmount.tax
        orderAmountEntity.amountWithoutTax = orderAmount.amountWithoutTax
        orderAmountEntity.numberOfItems = orderAmount.numberOfItems
        orderAmountEntity.state = orderAmount.state
        
        return orderAmountEntity
    }
}


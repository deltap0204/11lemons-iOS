//
//  AddOrderDetailGarmentTypesVM.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/5/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

protocol AddOrderDetailGarmentTypesVM {
    func getTotal(_ orderDetail: OrderDetail, order: Order) -> Double
    func getSubTotal(_ orderDetail: OrderDetail, order: Order) -> Double
    func getTax(_ orderDetail: OrderDetail) -> Double
}

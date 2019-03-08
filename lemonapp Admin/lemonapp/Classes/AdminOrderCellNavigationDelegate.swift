//
//  AdminOrderCellNavigationDelegate.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 18/04/2018.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

protocol AdminOrderCellNavigationDelegate: class {
    func receiptDetailOf(_ order: Order)
    func completeDetailOf(_ order: Order)
}

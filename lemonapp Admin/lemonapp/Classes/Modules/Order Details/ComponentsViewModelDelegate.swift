//
//  ComponentsViewModelDelegate.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/12/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

protocol ComponentsViewModelDelegate: class {
    func resetServicesToOrderDetail()
    func resetAttributesToOrderDetail()
    func changeLbs(_ lbs: Double)
    func getCurrentLbs() -> Double?
    func setTypeOfServiceToOrderDetail(_ position: Int, isSelected: Bool)
    func setupAttributesToOrderDetail(_ category: Category, attributes: [Attribute])
    func setTypeOfServiceWashFoldToOrderDetail(_ position: Int, isSelected: Bool)
    func setupOrder(_ order: Order)
    func changeOrderDetailToAdd(_ order: Order)
    func showModal(_ alert: UIAlertController)
}

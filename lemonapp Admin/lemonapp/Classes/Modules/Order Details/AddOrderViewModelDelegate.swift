//
//  AddOrderViewModelDelegate.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 1/26/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

protocol AddOrderViewModelDelegate: class {
    func clearScreen(_ withSuccess: Bool)
    func showModal(_ alert: UIAlertController)
}

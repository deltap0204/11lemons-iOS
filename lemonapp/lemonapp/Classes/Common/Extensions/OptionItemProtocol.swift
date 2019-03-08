//
//  OptionItemProtocol.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation

protocol OptionItemProtocol {
    
    var label: String { get }
    var image: UIImage? { get }
}

protocol PaymentCardProtocol: OptionItemProtocol {
    var id: Int? { get }
    var lightImage: UIImage? { get }
}
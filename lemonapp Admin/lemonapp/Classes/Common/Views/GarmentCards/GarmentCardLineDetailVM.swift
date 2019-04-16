//
//  GarmentCardLineDetailVM.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 2/24/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

final class GarmentCardLineDetailVM {
    
    let text: String
    let price: Double
    
    init(text: String, price: Double) {
        self.text = text
        self.price = price
    }
}
//
//  Float+Currency.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation

extension Float {
    
    func asCurrency() -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        return currencyFormatter.string(from: NSNumber(value: self)) ?? ""
    }
    
    func asCurrencyWithoutSymbol() -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        currencyFormatter.currencySymbol = ""
        return currencyFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}

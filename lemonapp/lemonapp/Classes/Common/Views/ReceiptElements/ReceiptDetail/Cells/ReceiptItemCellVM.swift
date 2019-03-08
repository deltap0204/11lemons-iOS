//
//  ReceiptItemCellVM.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 9/29/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation

class ReceiptItemSingleVM {
    let title: String
    let price: Double
    var subtitle: String
    let isNegative: Bool
    let cellIdentifier: String?
    
    init(title: String, subtitle: String, price: Double, cellIdentifier: String? = nil) {
        self.title = title
        self.price = price
        self.subtitle = subtitle
        self.isNegative = price < 0
        self.cellIdentifier = cellIdentifier
    }
    
    func getHeight() -> CGFloat {
        if let cellIdentifier = cellIdentifier {
            if cellIdentifier == ReceiptTotalDoubleCell.identifier {
                return ReceiptTotalDoubleCell.Height
            }
        }
        
        return ReceiptTotalCell.Height
    }
    
    func getTotalPrice() -> Double {
        return Double(0.0)
    }
}
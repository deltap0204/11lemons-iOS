//
//  ReceiptItemsSectionVM.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 9/29/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation

protocol zarasaCell {
    func getHeight() -> CGFloat
    func getTotalPrice() -> Double
}

class ReceiptItemsSectionVM {
    
    let isItemSection: Bool
    let departmentID: Int
    var items: [GarmentCardViewModel]
    var footerItems: [ReceiptItemSingleVM]
    let name: String
    let total: Double
    
    init(name: String, items: [GarmentCardViewModel] = [], footerItems: [ReceiptItemSingleVM] = [], isItemSection: Bool, departmentID: Int = 9999, total: Double = 0) {
        self.name = name
        self.items = items
        self.footerItems = footerItems
        self.departmentID = departmentID
        self.isItemSection = isItemSection
        self.total = total
    }
    
    func getSectionTotalHeight() -> CGFloat {
        var height = CGFloat(0)
        
        if isItemSection {
            items.forEach { row in
                height = height + row.getHeight()
            }
        } else {
            footerItems.forEach { row in
                height = height + row.getHeight()
            }
        }
        return height + ReceiptItemSectionView.Height
    }
    
    func getTotalPrice() -> Double {
        var totalPrice:Double = 0
        if isItemSection {
            items.forEach { item in
                totalPrice = totalPrice + item.getTotalPrice()
            }
        } else {
            return total
        }
        
        return totalPrice
    }
}
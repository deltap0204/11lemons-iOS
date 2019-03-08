//
//  ReceiptTotalCell.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 9/28/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import UIKit

class ReceiptTotalCell: UITableViewCell {

    static let identifier = "ReceiptTotalCell"
    static let Height = CGFloat(50)
    
    @IBOutlet fileprivate weak var lblTitleLeft: UILabel!
    @IBOutlet fileprivate weak var lblRight: UILabel!
    @IBOutlet fileprivate weak var lblSubtitle: UILabel!
    
    func setup(_ vm: ReceiptItemSingleVM) {
        self.selectionStyle = UITableViewCellSelectionStyle.none
        lblTitleLeft.text = vm.title
        lblSubtitle.isHidden = vm.subtitle.isEmpty
        lblSubtitle.text = vm.subtitle
        var priceText = String(format: "$%.2f", vm.price)

        if vm.price < 0 {
            let price = vm.price * -1
            priceText = String(format: "($%.2f)", price)
            lblRight.textColor = UIColor.red
        }
        
        lblRight.text = priceText
    }
    
}

//
//  ReceiptItemFooter.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 9/28/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import UIKit

final class ReceiptFooterVM {
    let totalPrice: Double
    
    init(total: Double) {
        self.totalPrice = total
    }
}

final class ReceiptItemFooter: UIView {

    static let Height = CGFloat(66)
    @IBOutlet fileprivate weak var lblTotal: UILabel!
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        
        if let view = Bundle.main.loadNibNamed("ReceiptItemFooter", owner: self, options: nil)![0] as? UIView {
            view.frame = self.frame
            self.addSubview(view)
        }
    }
    
    func setup(_ vm: ReceiptFooterVM) {
        lblTotal.text = String(format: "$%.2f", vm.totalPrice)
    }
}

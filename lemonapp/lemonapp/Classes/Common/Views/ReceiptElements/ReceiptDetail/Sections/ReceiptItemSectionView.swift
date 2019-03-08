//
//  ReceiptItemSectionView.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 9/28/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import UIKit

final class ReceiptItemSectionView: UIView {

    static let Height = CGFloat(60)
    
    @IBOutlet fileprivate weak var lblTitle: UILabel!
    @IBOutlet fileprivate weak var lblRight: UILabel!
    
    
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
        
        if let view = Bundle.main.loadNibNamed("ReceiptItemSectionView", owner: self, options: nil)![0] as? UIView {
            view.frame = self.frame
            self.addSubview(view)
        }
    }
    
    func setup(_ vm: ReceiptItemsSectionVM) {
        lblTitle.text = vm.name.uppercased()
        lblRight.text = String(format: "$%.2f", vm.getTotalPrice())
    }
}

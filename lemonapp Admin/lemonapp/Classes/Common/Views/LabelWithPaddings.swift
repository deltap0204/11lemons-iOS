//
//  LabelWithPaddings.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit

class LabelWithPaddings: UILabel {
    
    let paddings: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, paddings))
        self.frame.size.width += paddings.left + paddings.right
    }
}

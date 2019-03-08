//
//  OutlineButton.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit

final class OutlineButton : UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        borderWidth = 2
        setTitleColor(UIColor.white, for: UIControlState())
        setTitleColor(UIColor.appBlueColor, for: UIControlState.selected)
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                backgroundColor = UIColor.white
                borderColor = UIColor.appBlueColor
            } else {
                backgroundColor = UIColor.clear
                borderColor = UIColor.white
            }
        }
    }
}

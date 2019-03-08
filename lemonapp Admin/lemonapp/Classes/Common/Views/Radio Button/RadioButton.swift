//
//  RadioButton.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation
import UIKit

final class RadioButton : UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.alpha = 1.0
            } else {
                self.alpha = 0.25
            }
        }
    }
}

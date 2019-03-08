//
//  TransparentToolbar.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit


final class TransparentToolbar: UIToolbar {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        tintColor = UIColor.clear
        setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.any)
        setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    }
}

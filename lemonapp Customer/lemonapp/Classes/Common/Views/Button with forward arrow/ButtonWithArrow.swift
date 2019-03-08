//
//  ButtonWithArrow.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit


extension UIButton {
    
    func fixForwardArrow() {
        let leftInset = frame.size.width - 40
        let topInset = CGFloat(4)
        imageEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: 0, right: 0)
    }
    
    func fixBackArrow() {
        let rightInset = frame.size.width - 155
        let topInset = CGFloat(0)
        imageEdgeInsets = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: rightInset)
    }
}
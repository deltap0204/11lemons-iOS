//
//  UIViewController+Xib.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit


func classNameFromClass(_ classType: AnyClass) -> String {
    return NSStringFromClass(classType).components(separatedBy: ".").last!
}

extension UINib {
    convenience init(forClass classType: AnyClass) {
        self.init(nibName: classNameFromClass(classType), bundle: nil)
    }
}

extension UIView {
    
    static func fromNib() -> UIView? {
        let objects = Bundle.main.loadNibNamed(classNameFromClass(self), owner: nil, options: nil)
        if let UIElements = objects {
            let cell = UIElements.first as? UIView
            return cell
        }
        return nil
    }
    
    static func nib() -> UINib? {
        return UINib(forClass: self)
    }
}

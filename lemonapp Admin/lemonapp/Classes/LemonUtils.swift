//
//  LemonUtils.swift
//  lemonapp
//
//  Created by Mauro Taroco on 6/22/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

func makeConstraintUnderSafeAreaIfIsIphoneX(constraint: NSLayoutConstraint, baseValue: CGFloat) {
    if isIphoneX() {
        if let rootView = UIApplication.shared.keyWindow {
            constraint.constant = baseValue + rootView.safeAreaInsets.bottom
        }
    }
}

func makeButtonBottomContentInsetIfIsIphoneX(button: UIButton) {
    if isIphoneX() {
        if let rootView = UIApplication.shared.keyWindow {
            button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, rootView.safeAreaInsets.bottom, 0)
        }
    }
}

func isIphoneX() -> Bool {
    if let window = UIApplication.shared.keyWindow {
        if #available(iOS 11.0, *) {
            if (window.safeAreaInsets.top) > CGFloat(0.0) || window.safeAreaInsets != .zero {
                //print("iPhone X")
                return true
            }
            else {
                //print("Not iPhone X")
                return false
            }
        }
    }
    return false
}

func print(_ item: @autoclosure () -> Any, separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        Swift.print(item(), separator:separator, terminator: terminator)
    #endif
}


func delay(_ delay: Double, closure: @escaping () -> ()) {
    
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}

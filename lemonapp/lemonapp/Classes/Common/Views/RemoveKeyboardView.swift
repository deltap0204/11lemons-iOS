//
//  RemoveKeyboardView.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit

final class RemoveKeyboardView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(RemoveKeyboardView.hideKeyboard))
        swipeRecognizer.direction = .down
        self.addGestureRecognizer(swipeRecognizer)
    }
    
    @objc func hideKeyboard() {
        
        if let firstResponder = UIView.findFirstResponder(self) {
            firstResponder.resignFirstResponder()
        }
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        if let firstResponder = UIView.findFirstResponder(self.window ?? self) {
            
            if hitView == nil || !hitView!.canBecomeFirstResponder {
                firstResponder.perform(#selector(UIResponder.resignFirstResponder), with: nil, afterDelay: 0.1)
            }
        }        
        
        return hitView
    }
}

extension UIView {
    
    
    static func findFirstResponder(_ parent:UIView) -> UIView? {
        
        if parent.isFirstResponder {
            return parent
        } else if parent.subviews.count > 0 {
            return parent.subviews.flatMap { findFirstResponder($0) }.first
        } else {
            return nil
        }
    }
}

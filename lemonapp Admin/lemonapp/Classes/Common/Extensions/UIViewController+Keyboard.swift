//
//  UIViewController+Keyboard.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


extension UIViewController {
    
    func subscribeForKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.updateViewWithKeyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func updateViewWithKeyboardNotification(_ notification: Notification) {
        
        if let keyboardListener = (self as? KeyboardListenerProtocol),
            let aboveKeyboardView = keyboardListener.getAboveKeyboardView(),
            let rootView = self.navigationController?.view ?? self.view {
                
                let holdNavigationBar = (self as? KeyboardListenerProtocol)?.holdNavigationBar ?? false
                
                let navigationBar = holdNavigationBar ? self.findNavigationBar(rootView) : nil
                var navigationBarFrame = navigationBar?.frame
                
                var userInfo = notification.userInfo!
                let frameEnd = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
                let absoluteOriginYBottomView = absoluteOriginYOfView(aboveKeyboardView)
                
            let heightOffset = absoluteOriginYBottomView + aboveKeyboardView.bounds.size.height - (frameEnd?.origin.y)!
                
                let curve = (userInfo[UIKeyboardAnimationCurveUserInfoKey]! as AnyObject).uint32Value
                let options = UIViewAnimationOptions(rawValue: UInt(curve!) << 16)
                
                var rootFrame = rootView.frame
                let windowFrame = rootView.window?.bounds
                
                //for 4" and 3.5" screens
                if frameEnd?.origin.y >= windowFrame?.size.height {
                    rootFrame.size.height = (frameEnd?.origin.y)!
                    rootView.frame = rootFrame
                }
                
            rootFrame.origin.y = rootFrame.height == frameEnd?.origin.y ? 0 : rootFrame.origin.y - heightOffset
                rootFrame.origin.y = rootFrame.origin.y > 0 ? 0 : rootFrame.origin.y
                navigationBarFrame?.origin.y = rootFrame.origin.y == 0 ? 20 : -rootFrame.origin.y + 20
                
                //for 4" and 3.5" screens
                if rootFrame.size.height + rootFrame.origin.y < absoluteOriginYBottomView {
                    rootFrame.size.height += heightOffset
                }
                
                UIView.animate(
                    withDuration: (userInfo[UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue,
                    delay: 0,
                    options: options,
                    animations: {
                        rootView.frame = rootFrame
                        navigationBar?.frame = navigationBarFrame ?? CGRect.zero
                    },
                    completion: nil
                )
        }
    }

    fileprivate func findNavigationBar(_ rootView: UIView) -> UINavigationBar? {
        if let navigationBar = rootView as? UINavigationBar {
            return navigationBar
        } else {
            return rootView.subviews.flatMap { findNavigationBar($0) }.first
        }
    }
    
    func unsubscribe() {
        
        NotificationCenter.default.removeObserver(self)
    }
}


protocol KeyboardListenerProtocol {
    
    var holdNavigationBar: Bool { get }
    
    func getAboveKeyboardView() -> UIView?
}

extension KeyboardListenerProtocol {
    var holdNavigationBar: Bool {
        return false
    }
}

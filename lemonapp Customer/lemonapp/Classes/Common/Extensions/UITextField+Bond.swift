//
//  UITextField+Bond.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond

extension UITextField {
    
    fileprivate struct AssociatedKeys {
        static var FocusKey = "bnd_FocusedKey"
    }
    var bnd_focused:Observable<Bool> {
        if let bnd_focused: Observable<Bool> = objc_getAssociatedObject(self, &AssociatedKeys.FocusKey) as? Observable<Bool> {
            return bnd_focused
        } else {
            let bnd_focused = Observable<Bool>(self.isFirstResponder)
            objc_setAssociatedObject(self, &AssociatedKeys.FocusKey, bnd_focused, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            var updatingFromSelf: Bool = false
            
            bnd_focused.skip(first: 1).observeNext { [weak self] (focused: Bool) in
                if !updatingFromSelf {
                    if focused {
                        self?.becomeFirstResponder()
                    } else {
                        self?.resignFirstResponder()
                    }
                }
            }
            
            NotificationCenter.default.bnd_notification(NSNotification.Name.UITextFieldTextDidBeginEditing, object: self).observeNext { [weak bnd_focused] notification in
                if let textField = notification.object as? UITextField, let bnd_focused = bnd_focused {
                    if textField == self {
                        updatingFromSelf = true
                        bnd_focused.next(textField.isFirstResponder)
                        updatingFromSelf = false
                    }
                }
                }.dispose(in: bag)
            
            NotificationCenter.default.bnd_notification(NSNotification.Name.UITextFieldTextDidEndEditing, object: self).observeNext { [weak bnd_focused] notification in
                if let textField = notification.object as? UITextField, let bnd_focused = bnd_focused {
                    if textField == self {
                        updatingFromSelf = true
                        bnd_focused.next(textField.isFirstResponder)
                        updatingFromSelf = false
                    }
                }
                }.dispose(in: bag)
            
            return bnd_focused
        }
        
    }
}

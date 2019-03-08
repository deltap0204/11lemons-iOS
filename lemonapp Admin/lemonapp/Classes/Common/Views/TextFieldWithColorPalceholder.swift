//
//  TextFieldWithColorPalceholder.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

@IBDesignable
final class TextFieldWithColorPalceholder: TextFieldWithNext {
    
    var attrs: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.5) ]
    
    @IBInspectable var placeholderColor: UIColor = UIColor(white: 1.0, alpha: 0.5) { didSet {
        attrs = [NSAttributedStringKey.foregroundColor: placeholderColor]
        attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes:attrs)
    } }
    
    override var keyboardType: UIKeyboardType {
        didSet {
            if (self.isFirstResponder) {
                    //resignFirstResponder()
                    //becomeFirstResponder()
            }
        }
    }
    
    override var placeholder: String? {
        didSet {
            attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes:attrs)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes:attrs)
        self.autocorrectionType = .no
        
        if #available(iOS 10, *) {
            // Disables the password autoFill accessory view.
            self.textContentType = UITextContentType("")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes:attrs)
        self.autocorrectionType = .no
        
        if #available(iOS 10, *) {
            // Disables the password autoFill accessory view.
            self.textContentType = UITextContentType("")
        }
    }
}

extension UITextField {
    
    public var bnd_placeholder: DynamicSubject<String?> {
        return self.reactive.keyPath("placeholder", ofType: String?.self)
    }
}

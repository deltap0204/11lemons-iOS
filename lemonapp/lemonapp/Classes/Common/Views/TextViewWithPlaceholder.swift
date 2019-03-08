//
//  TextViewWithPlaceholder.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit

final class TextViewWithPlaceholder: UIView {
    
    
    @IBOutlet fileprivate weak var placeholderLabel: UILabel!
    @IBOutlet fileprivate weak var textView: UITextView! {
        didSet {
            
            self.textView.bnd_text.observeNext { [weak self] in
                if let text = $0 {
                    self?.placeholderLabel.isHidden = !text.isEmpty
                } else {
                    self?.placeholderLabel.isHidden = false
                }
            }
            self.textView.contentInset = UIEdgeInsets(top: 14, left: -4, bottom: 0, right: 0)
        }
    }
}


//
//  TextFieldWithNext.swift
//  lemonapp
//
//  Created by mac-190-mini on 1/19/16.
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit

class TextFieldWithNext: UITextField {
    
    @IBOutlet weak var nextTextField: UITextField?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self    
    }
    
}

extension TextFieldWithNext: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = (textField as? TextFieldWithNext)?.nextTextField {
            if nextTextField.canBecomeFirstResponder {
                nextTextField.becomeFirstResponder()
            } else {
                nextTextField.delegate?.textFieldShouldReturn?(nextTextField)
            }
            return false
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

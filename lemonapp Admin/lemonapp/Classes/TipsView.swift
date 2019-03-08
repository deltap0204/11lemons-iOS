//
//  TipsView.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


class TipsView: TextFieldWithPicker {
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
    
    override func selectionRects(for range: UITextRange) -> [Any] {
        return []
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return !(action == #selector(copy(_:)) || action == #selector(selectAll(_:)) || action == #selector(paste(_:))) ? super.canPerformAction(action, withSender: sender) : false
    }
}

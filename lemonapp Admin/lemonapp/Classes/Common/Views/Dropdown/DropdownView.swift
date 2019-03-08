//
//  DropdownView.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond


final class DropdownView: UIView {
    
    @IBOutlet fileprivate weak var showOptionsButton: UIButton!

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var optionLabel: UILabel!
    @IBOutlet fileprivate weak var dropdownButton: UIButton!
    
    var enabled = Observable(true)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupState()
    }
    
    fileprivate func setupState() {
        enabled.observeNext { [weak self] isEnabled in
            self?.alpha = isEnabled ? 1 : 0.25
            self?.isUserInteractionEnabled = isEnabled
        }
    }
}

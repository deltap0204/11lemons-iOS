//
//  RadioButtonGroup.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond


class RadioButtonGroup: UIControl {
    
    @IBOutlet var buttons:[UIButton]? {
        didSet {
            buttons?.sort { $0.tag < $1.tag }
        }
    }
    
    var valueTitles: [String]? {
        didSet {
            if let titles = valueTitles {
                for (index, title) in titles.enumerated() {
                    buttons?[index].setTitle(title)
                }
            }
        }
    }
    
    var selectedValueIndex = Observable(0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttons?.sort { $0.tag < $1.tag }
        
        selectedValueIndex.observeNext { [weak self] index in
            if let button = self?.buttons?[index], !button.isSelected {
                self?.deselectAllButtonsBesidesButton(button)
            }
        }

        buttons?.forEach { button in
            button.bnd_tap.observeNext { [weak self] in
                if !button.isSelected {
                    self?.deselectAllButtonsBesidesButton(button)
                }
            }
        }
    }
    
    fileprivate func deselectAllButtonsBesidesButton(_ button: UIButton) {
        button.isSelected = true
        self.buttons?.filter {$0 !== button}.forEach { $0.isSelected = false }
        if let index = self.buttons?.index(of: button) {
            self.selectedValueIndex.value = index
        }
    }
}

//
//  FrequencySlider.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond


final class FrequencySlider: UISlider {
    
    let frequency = Observable(0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        minimumValue = 0
        maximumValue = 4
        value = 0
        frequency.next(0)
        addTarget(self, action: #selector(FrequencySlider.valueChanged), for: UIControlEvents.valueChanged)
        
        frequency.observeNext{ [weak self] newValue in
            //self?.setValue(Float(newValue), animated: true)
            //self?.valueChanged()
        }
        bnd_value.observeNext { [weak self] in self?.isSelected = $0 == 0 }
    }
    
    @objc func valueChanged() {
        let rounded = roundf(value)
        bnd_value.next(rounded)
        frequency.next(Int(rounded))
    }
}

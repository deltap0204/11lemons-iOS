//
//  DayCell.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation

final class DayCell: UICollectionViewCell {
    
    var day: Int? {
        didSet {
            if let day = day {
                if day == 0 {
                    label.text = ""
                } else {
                    label.text = "\(day)"
                }
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                backgroundColor = UIColor.appBlueColor
                layer.cornerRadius = frame.width / 2
            } else {
                backgroundColor = UIColor.clear
            }
        }
    }
    
    var active = true {
        didSet {
            label.alpha = active ? 1.0 : 0.25
            if !active {
                isSelected = false
            }
        }
    }
    
    @IBOutlet var label: UILabel!

}

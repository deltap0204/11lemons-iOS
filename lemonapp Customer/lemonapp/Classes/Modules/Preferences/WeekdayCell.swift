//
//  WeekdayCell.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation

final class WeekdayCell: UICollectionViewCell {
    
    var weekday: Weekday?
    
    var weekdayName: String? {
        didSet {
            if let weekdayName = weekdayName {
                //label?.text = weekdayName.substringToIndex(weekdayName.characters.index(weekdayName.startIndex, offsetBy: 1)).uppercased()
                label?.text = weekdayName.substring(to: weekdayName.index(weekdayName.startIndex, offsetBy: 1)).uppercased()
            }
        }
    }
    
    var active = true {
        didSet {
            label?.alpha = active ? 1.0 : 0.25
            isUserInteractionEnabled = active
        }
    }
    
    @IBOutlet var label: UILabel?
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor.appBlueColor : UIColor.clear
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = frame.width / 2
    }
}

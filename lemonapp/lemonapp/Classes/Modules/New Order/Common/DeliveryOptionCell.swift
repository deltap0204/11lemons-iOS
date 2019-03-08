//
//  DeliveryOptionCell.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit


final class DeliveryOptionCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var checkmarkIcon: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel.textColor = UIColor.white
                backgroundColor = UIColor.appBlueColor
            } else {
                titleLabel.textColor = UIColor.appBlueColor
                backgroundColor = UIColor.white
            }
            checkmarkIcon.isHidden = !isSelected
        }
    }
    
    var deliveryOption: DeliveryPricing? {
        didSet {
            if let option = deliveryOption {
                let textColor = isSelected ? UIColor.white : UIColor.appBlueColor
                
                let weekdayAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 13), NSAttributedStringKey.foregroundColor: textColor]
                let weekday = "\(option.weekdayTitleForDate(Date()))\n"
                let text = NSMutableAttributedString(string: weekday, attributes: weekdayAttributes)
                
                let priceAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13), NSAttributedStringKey.foregroundColor: textColor]
                let price = option.priceForDate(Date())
                let priceText = NSAttributedString(string: price, attributes: priceAttributes)
                
                text.append(priceText)
                
                titleLabel.attributedText = text
            }
        }
    }
}

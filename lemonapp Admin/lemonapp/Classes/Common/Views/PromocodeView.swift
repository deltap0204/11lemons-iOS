//
//  PromocodeView.swift
//  lemonapp
//
//  Created by Svetlana Dedunovich on 4/25/16.
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit


final class PromocodeView: UIView {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var placeholder: UILabel!
    
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var promocodeIsValid: Bool? {
        didSet {
            
            if let isValid = promocodeIsValid {
                iconView.isHidden = false
                
                if isValid {
                    textField.textColor = UIColor.appBlueColor
                    iconView.image = UIImage(assetIdentifier: UIImage.AssetIdentifier.ValidationSuccess)
                    backgroundColor = UIColor(white: 1, alpha: 1.0)
                } else {
                    textField.textColor = UIColor.attentionColor
                    iconView.image = UIImage(assetIdentifier: UIImage.AssetIdentifier.ValidationError)
                    backgroundColor = UIColor(white: 1, alpha: 0.75)
                }
                if textField.text?.count == 0 {
                    iconView.isHidden = true
                }
            } else {
                textField.text = nil
                textField.textColor = UIColor.appBlueColor
                
                iconView.isHidden = true
                
                placeholder.textColor = UIColor.appBlueColor
                placeholder.isHidden = false
                
                backgroundColor = UIColor(white: 1, alpha: 0.75)
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.isHidden = true
    }
    
    @IBAction func textFieldDidBeginEditing() {
        placeholder.isHidden = true
        textField.textColor = UIColor.appBlueColor
        iconView.isHidden = true
    }
    
    
    @IBAction func textFieldDidEndEditing() {
        placeholder.isHidden = !(textField.text ?? "").isEmpty
    }
}

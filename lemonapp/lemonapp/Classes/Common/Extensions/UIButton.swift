//
//  UIButton.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    @IBInspectable var numberOfLines: Int {
        get {
            return self.titleLabel?.numberOfLines ?? 0
        }
        set {
            self.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            self.titleLabel?.numberOfLines = numberOfLines
            self.titleLabel?.textAlignment = NSTextAlignment.center
        }
    }
    
    func setTitle(_ title: String) {
        setTitle(title, for: UIControlState())
    }
    
    
    func centerImageAndTitleWithSpacing(_ spacing: CGFloat) {
        // get the size of the elements here for readability
        let imageSize = self.imageView!.frame.size;
        let titleSize = self.titleLabel!.frame.size;
    
        // get the height they will take up as a unit
        let totalHeight = (imageSize.height + titleSize.height + spacing);
    
        // raise the image and push it right to center it
        self.imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight - imageSize.height), 0.0, 0.0, -titleSize.width);
        
        // lower the text and push it left to center it
        self.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize.width, -(totalHeight - titleSize.height),0.0);
    }
    
    func centerImageAndTitle() {
        centerImageAndTitleWithSpacing(3)
    }
}

//
//  LemonBackground.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {
    
    func setLemonBackground() {
        self.view.backgroundColor = UIColor(patternImage: UIImage(assetIdentifier: .TopLeftLemonBg) )
        let overlayView = UIView(frame: self.view.bounds)
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        overlayView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.insertSubview(overlayView, at: 0)
    }
    
    func setBlurredLemonBackground() {
        self.view.backgroundColor = UIColor(patternImage: UIImage(assetIdentifier: .BlurredLemonBg) )
    }
    
}

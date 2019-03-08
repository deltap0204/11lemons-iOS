//
//  UIView.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit

func absoluteOriginYOfView(_ view: UIView?) -> CGFloat {
    if let view = view {
        return view.frame.origin.y + absoluteOriginYOfView(view.superview ?? view.window)
    } else {
        return 0
    }
}
extension UIView {
    func makeTopShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: -1.0)
        self.layer.shadowOpacity = 0.7
        self.layer.masksToBounds = false
    }
}

extension UIView {
    
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

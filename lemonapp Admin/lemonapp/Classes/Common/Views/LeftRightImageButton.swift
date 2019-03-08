//
//  LeftRightImageButton.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit

enum ImagePosition {
    case left, right
}

final class LeftRightImageButton: HighlightedButton {
    
    static let IMAGE_MARGIN: CGFloat = 22
    
    var imagePosition: ImagePosition = .right {
        didSet {
            layoutSubviews()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageFrame = imageView?.frame, imageFrame.size.width > 0 {
            switch imagePosition {
            case ImagePosition.left:
                if round(imageFrame.origin.x) > LeftRightImageButton.IMAGE_MARGIN {
                    let right = round(imageFrame.origin.x) - LeftRightImageButton.IMAGE_MARGIN
                    self.imageEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: self.imageEdgeInsets.right + right)
                }
                break
            default:
                if round(imageFrame.origin.x) < self.bounds.size.width - LeftRightImageButton.IMAGE_MARGIN - imageFrame.width {
                    let left = self.bounds.size.width - imageFrame.size.width - LeftRightImageButton.IMAGE_MARGIN - round(imageFrame.origin.x)
                    self.imageEdgeInsets = UIEdgeInsets(top: 4, left: self.imageEdgeInsets.left + left, bottom: 0, right: 0)
                }
                break
            }
        }
    }
}

//
//  CircularButtonWithTitle.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


final class CircularButtonWithTitle : UIButton {
    
    @IBOutlet var label: UILabel?
    @IBOutlet var icon: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTitleColor(UIColor.appBlueColor, for: UIControlState())
        setTitleColor(UIColor.appBlueColor, for: UIControlState.selected)
        alignTitleToBottom()
    }
    
    override var isSelected: Bool {
        didSet {
            alignTitleToBottom()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        alignTitleToBottom()
    }
    
    fileprivate func alignTitleToBottom() {
        
        let maxHeightImageSize = max(image(for: UIControlState())?.size.height ?? 0, image(for: .selected)?.size.height ?? 0)
        let minHeightImageSize = min(image(for: UIControlState())?.size.height ?? 0, image(for: .selected)?.size.height ?? 0)
        let bottom = (maxHeightImageSize - minHeightImageSize) / 3
        let imageSize = imageView!.frame.size
        let titleSize = titleLabel!.frame.size
        titleLabel?.textAlignment = NSTextAlignment.center
        
        if isSelected {
            imageEdgeInsets = UIEdgeInsets(top: -bottom/2, left: 0, bottom: bottom, right: 0)
            titleEdgeInsets = UIEdgeInsets(top: self.frame.size.height - titleSize.height, left: -frame.width + (frame.width - titleSize.width) / 2, bottom: 0, right: 0)
        } else {
            let inset = (frame.width - imageSize.width) / 2
            imageEdgeInsets = UIEdgeInsets(top: bottom, left: inset, bottom: 0, right: 0)
            titleEdgeInsets = UIEdgeInsets(top: self.frame.size.height - titleSize.height, left: (-imageSize.width + (frame.width - titleSize.width) / 2), bottom: 0, right: 0)
        }
        titleLabel!.center.x = frame.size.width / 2
    }
}

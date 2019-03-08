//
//  ActivityButton.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond

enum ActivityButtonState {
    case idle
    case busy
}

final class ActivityButton: HighlightedButton {
    
    fileprivate var activityIndicator: UIActivityIndicatorView  = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    let activityState = Observable(ActivityButtonState.idle)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    fileprivate func initialize() {
        self.addSubview(activityIndicator)
        
        var frame = activityIndicator.frame
        frame.origin.x = self.bounds.width - frame.width - 15
        frame.origin.y = (self.bounds.height - frame.height) / 2
        activityIndicator.frame = frame
        activityIndicator.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleTopMargin]
        
        activityState.map { $0 == .busy }.bind(to: activityIndicator.bnd_animating)
        activityState.map { $0 == .idle }.bind(to: activityIndicator.bnd_hidden)
        activityState.map { $0 == .idle }.bind(to: bnd_userInteractionEnabled)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

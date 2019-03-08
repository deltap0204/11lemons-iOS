//
//  LoadingOverlay.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit

private final class LoadingOverlay: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge))
    }
    
    override func layoutSubviews() {
        subviews.first?.center.x = bounds.midX
        subviews.first?.center.y = bounds.midY
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating() {
        (subviews.first as? UIActivityIndicatorView)?.startAnimating()
    }
}

func showLoadingOverlay() {
    if let keyWindow = UIApplication.shared.keyWindow {
        keyWindow.endEditing(true)
        
        let loadingOverlay = LoadingOverlay(frame: keyWindow.bounds)
        loadingOverlay.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: {
            loadingOverlay.alpha = 1
            }, completion: nil)
        keyWindow.addSubview(loadingOverlay)
        loadingOverlay.startAnimating()
    }
}

func hideLoadingOverlay() {
    if let keyWindow = UIApplication.shared.keyWindow {
        keyWindow.subviews.forEach {
            if let loadingOverlay = $0 as? LoadingOverlay {
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: {
                    loadingOverlay.alpha = 0
                    }, completion: { _ in
                        loadingOverlay.removeFromSuperview()
                })
            }
        }
    }
}

//
//  NotificationView.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit

final class NotificationView: UIView {
    
    enum State {
        case success
        case progress
        case error(message: String)
        
        var icon: UIImage? {
            switch self {
            case .success:
                return UIImage(assetIdentifier: UIImage.AssetIdentifier.SuccessIcon)
            case .error:
                return UIImage(assetIdentifier: UIImage.AssetIdentifier.AlertIcon)
            case .progress:
                return nil
            }
        }
        
        var color: UIColor {
            switch self {
            case .success:
                return UIColor.appBlueColor
            case .error:
                return UIColor.attentionColor
            case .progress:
                return UIColor.clear
            }
        }
    }
    
    var state: State? {
        didSet {
            if let state = state {
                switch state {
                case .success:
                    label.text = "Success"
                    activityIndicator.isHidden = true
                case .error(let message):
                    label.text = message
                    activityIndicator.isHidden = true
                case .progress:
                    label.text = ""
                    activityIndicator.isHidden = false
                    activityIndicator.startAnimating()
                }
                icon.image = state.icon
                backgroundColor = state.color
                isHidden = false
            } else {
                isHidden = true
            }
        }
    }
    
    @IBOutlet var label: UILabel!
    @IBOutlet var icon: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    static let sharedInstance: NotificationView = NotificationView.fromNib() as! NotificationView
    
    static func showForState(_ state: State, inView view: UIView, addNavBarOffset: Bool = true) {
        let notification = sharedInstance
        notification.state = state
        notification.center = view.center
        notification.frame.origin.y = addNavBarOffset ? 70 : 5;
        notification.alpha = 0.0
        notification.setNeedsLayout()
        view.addSubview(notification)
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            notification.alpha = 1.0
            }, completion: { _ in
                switch state {
                case .error:
                    let animation = CAKeyframeAnimation()
                    animation.keyPath = "position.x"
                    animation.values = [0, 10, -10, 10, 0];
                    animation.keyTimes = [0, NSNumber(value: (1 / 6.0)), NSNumber(value: (3 / 6.0)), NSNumber(value: (5 / 6.0)), 1]
                    animation.duration = 0.4
                    animation.isAdditive = true
                    notification.layer.add(animation, forKey: "shake")
                default: ()
                }
                let timer = Timer(fireAt: Date(timeIntervalSinceNow: 2), interval: 0.0, target: NotificationView.self, selector: #selector(NotificationView.hideAnimated), userInfo: nil, repeats: false)
                RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)

        }) 
    }
    
    
    static func hide() {
        sharedInstance.removeFromSuperview()
    }
    
    
    @objc static func hideAnimated() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            sharedInstance.alpha = 0.0
            }, completion: { _ in
                sharedInstance.removeFromSuperview()
        }) 
    }
}

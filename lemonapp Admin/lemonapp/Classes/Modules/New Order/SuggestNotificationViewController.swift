//
//  SuggestNotificationViewController.swift
//  lemonapp
//
//  Created by Svetlana Dedunovich on 5/4/16.
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit


final class SuggestNotificationViewController: UIViewController {
    
    typealias OnComplete = (_ turnOnNotifications: Bool) -> Void
    
    var completion: OnComplete?
    
    
    @IBAction func turnOnNotifications() {
        completion?(true)
    }
    
    
    @IBAction func turnOffNotifications() {
        completion?(false)
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    static func fromNib() -> SuggestNotificationViewController {
        return SuggestNotificationViewController(nibName: "SuggestNotificationView", bundle: nil)
    }
}

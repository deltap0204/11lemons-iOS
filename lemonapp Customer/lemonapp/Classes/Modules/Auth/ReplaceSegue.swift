//
//  ShowHomeSegue.swift
//  lemonapp
//
//  Created by mac-190-mini on 12/29/15.
//  Copyright © 2015 11lemons. All rights reserved.
//

import UIKit

final class ReplaceSegue: UIStoryboardSegue {
    
    override func perform() {
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            // Access the app's key window and insert the destination view above the current (source) one.
            let window = UIApplication.shared.keyWindow
            let firstVCView = appDelegate.window?.rootViewController?.view as UIView!
            appDelegate.window?.rootViewController = self.destination
            
            window?.addSubview(firstVCView!)
            UIView.animate(withDuration: 0.5, animations: {
                firstVCView?.alpha = 0
                }, completion: { _ in
                    firstVCView?.removeFromSuperview()
            })
        }        
    }
}

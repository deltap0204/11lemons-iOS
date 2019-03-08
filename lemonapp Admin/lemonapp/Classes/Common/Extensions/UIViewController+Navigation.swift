//
//  UIViewController+Navigation.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit

extension UIViewController {
    
    @IBAction func onBack(_ sender: AnyObject?) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onMenu(_ sender: AnyObject?) {
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
}

@objc extension UIViewController {
    func onExit() {
        
    }
}

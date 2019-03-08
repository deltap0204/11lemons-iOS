//
//  File.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import UIKit

final class StartNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        
        let notFirstLaunch = UserDefaults.standard.bool(forKey: NSUserDefaultsDataKeys.NotFirstLaunch.rawValue)
        if notFirstLaunch {
            guard let signInVC = storyboard?.instantiateViewControllerWithIdentifier(.SignInScreen) else {
                return
            }
            setViewControllers([signInVC], animated: false)            
        }
    }
}

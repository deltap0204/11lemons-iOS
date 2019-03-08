//
//  File.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import UIKit

final class StartNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        
        let unnecessaryInstructions = NSUserDefaults.standardUserDefaults().boolForKey(NSUserDefaultsDataKeys.UnnecessaryInstructions.rawValue)
        if unnecessaryInstructions {
            guard let signInVC = storyboard?.instantiateViewControllerWithIdentifier(.SignInScreen) else {
                return
            }
            setViewControllers([signInVC], animated: false)
        }
        
    }
}

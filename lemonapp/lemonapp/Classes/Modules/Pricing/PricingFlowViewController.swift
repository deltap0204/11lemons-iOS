//
//  PricingFlowViewController.swift
//  lemonapp
//
//  Created by mac-190-mini on 2/8/16.
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit

final class PricingFlowViewController: UIViewController {
    
    var router: PricingRouter?
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ((childViewControllers.first as? UINavigationController)?.viewControllers.first as? PricingViewController)?.router = router
    }
}

//
//  TransparentNavigationController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit

final class TransparentNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()        

        navigationBar.tintColor = UIColor.white
        
        UIBarButtonItem.appearance().setBackButtonBackgroundImage(nil, for: UIControlState(), barMetrics: .default)
        
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        navigationBar.backIndicatorImage = UIImage(assetIdentifier: .WhiteBackArrow).resizableImage(withCapInsets: UIEdgeInsets(top: 12, left: 20, bottom: 0, right: 0))
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

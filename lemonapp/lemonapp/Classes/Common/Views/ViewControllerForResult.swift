//
//  ViewControllerForResult.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit

protocol ViewControllerForResult {
    
    var onResultHandler: ((_ result: AnyObject?) -> ())? {get set}
    
    func popViewController()
}

extension ViewControllerForResult {
    
    func returnResult(_ result: AnyObject?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.onResultHandler?(result)
        }
        
        self.popViewController()
        
        CATransaction.commit()
    }
}

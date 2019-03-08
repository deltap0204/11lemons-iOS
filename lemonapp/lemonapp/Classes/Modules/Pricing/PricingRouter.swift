//
//  PricingRouter.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit

final class PricingRouter {
    
    fileprivate weak var menuRouter: MenuRouter?
    
    init(menuRouter: MenuRouter) {
        self.menuRouter = menuRouter
    }
    
    func showOrdersFlow() {
        menuRouter?.showOrdersFlow()
    }    
}

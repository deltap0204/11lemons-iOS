//
//  CloudClosetRouter.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

final class CloudClosetRouter {
    
    fileprivate weak var menuRouter: MenuRouter?
    
    init(menuRouter: MenuRouter) {
        self.menuRouter = menuRouter
    }
    
    func showOrders() {
        menuRouter?.showOrdersFlow()
    }
}


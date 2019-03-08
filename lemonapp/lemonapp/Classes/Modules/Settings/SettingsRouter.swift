//
//  SettingsRouter.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

final class SettingsRouter {
    
    fileprivate weak var menuRouter: MenuRouter?
    
    init(menuRouter: MenuRouter) {
        self.menuRouter = menuRouter
    }
    
    func showOrders() {
        menuRouter?.showOrdersFlow()
    }
}

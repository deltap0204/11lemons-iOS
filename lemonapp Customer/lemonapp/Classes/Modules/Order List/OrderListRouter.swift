//
//  OrderListRouter.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit


final class OrderListRouter {
    
    fileprivate weak var menuRouter: MenuRouter?
    
    init(menuRouter: MenuRouter) {
        self.menuRouter = menuRouter
    }
    
    func showNewOrderFlow() {
        menuRouter?.showNewOrderFlow()
    }
    
    func showEditOrderFlow(_ editedOrder: Order) {
        menuRouter?.showEditOrderFlow(editedOrder)
    }
    
    func showOrderServicesFlow(_ order: Order) {
        menuRouter?.showOrderServicesFlow(order)
    }
    
    func showOrderrReceiptFlow(_ order: Order) {
        menuRouter?.showOrderReceiptFlow(order)
    }
    
}

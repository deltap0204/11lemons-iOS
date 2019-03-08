//
//  OrderStatusFlow.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit


final class OrderStatusFlow {
    
    typealias Completion = () -> Void
    
    fileprivate let viewController: UIViewController
    fileprivate let completion: Completion
    fileprivate let order: Order
    
    init(withOrder order: Order, fromViewController viewController: UIViewController, completion: @escaping Completion) {
        self.viewController = viewController
        self.completion = completion
        self.order = order
        start()
    }
    
    fileprivate func start() {
        showStatusPicker()
    }
    
    fileprivate func showStatusPicker() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for status in order.status.otherAvailableStatuses {
            alert.addAction(UIAlertAction(title: status.subtitle, style: .default, handler: { _ in
                _ = LemonAPI.setOrderStatus(editedOrder: self.order, status: status).request().observeNext { [weak self] (result: EventResolver<Order>) in
                    DataProvider.sharedInstance.refreshAdminOrders() { _ in
                        self?.completion()
                    }
                }
                return
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        viewController.present(alert, animated: true, completion: nil)
    }
}

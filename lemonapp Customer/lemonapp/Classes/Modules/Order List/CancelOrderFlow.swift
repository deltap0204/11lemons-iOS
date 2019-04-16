//
//  CancelOrderFlow.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit

enum CancelOrderFlowResult {
    case cancel
    case success
}

final class CancelOrderFlow {
    
    typealias Completion = (_ result: CancelOrderFlowResult) -> Void
    
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
        showConfirmationAlert()
    }
    
    fileprivate func showConfirmationAlert() {
        let alert = UIAlertController(title: "Are you sure you want to cancel your order?", message: "If you need to make a change you can always call us at (914) 249-9534", preferredStyle: UIAlertControllerStyle.alert)
        
        let no = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) {_ in
            self.completion(.cancel)
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(no)
        
        let yes = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { _ in
            alert.dismiss(animated: true, completion: nil)
            self.showCancelAlert()
        }
        
        alert.addAction(yes)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func showCancelAlert() {
        let alert = UIAlertController(title: "Cancel Order", message: "Please help improve our service by providing a reason for your cancellation.", preferredStyle: UIAlertControllerStyle.alert)

        let back = UIAlertAction(title: "Go Back", style: UIAlertActionStyle.cancel) { _ in
            self.completion(.cancel)
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(back)
        
        let confirmCancel = UIAlertAction(title: "Delete Confirmation", style: UIAlertActionStyle.default) { _ in
            alert.dismiss(animated: true, completion: nil)
            showLoadingOverlay()
            _ = LemonAPI.cancelOrder(orderId: self.order.id).request().observeNext { (result: EventResolver<Order>) in
                hideLoadingOverlay()
                do {
                    let order = try result()
                    if order.status == OrderStatus.canceled {
                        self.completion(.success)
                        return
                    }
                } catch {
                    self.completion(.success)
                }
            }
        }
        alert.addAction(confirmCancel)
        
        alert.addTextField { textField in
            textField.placeholder = "Why are you cancelling?"
        }
        
        viewController.present(alert, animated: true, completion: nil)
    }
}

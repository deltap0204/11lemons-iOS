//
//  UIViewController+Alert.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import UIKit

extension UIViewController {
    
    
    typealias AlertAction = ((UIAlertAction) -> ())?
    func showAlert(_ title: String?, message: String?, positiveButton: String? = "OK", positiveAction: AlertAction = nil,  cancelButton: String? = nil, cancelAction:  AlertAction = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let positiveButton = positiveButton {
            alert.addAction(UIAlertAction(title: positiveButton, style: .default, handler: positiveAction))
        }
        if let cancelButton = cancelButton {
            alert.addAction(UIAlertAction(title: cancelButton, style: .cancel, handler: cancelAction))
        }
        present(alert, animated: true, completion: nil)
    }
}

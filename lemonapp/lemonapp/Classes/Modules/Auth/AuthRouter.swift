//
//  AuthRouter.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import DrawerController


final class AuthRouter {
    
    func openHome(_ animated: Bool) {
        MenuRouter().showLanding(animated)
    }
}

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
    
    let menuRouter = MenuRouter()
    
    func openHome(_ animated: Bool) {
        menuRouter.showLanding(animated)
    }
}

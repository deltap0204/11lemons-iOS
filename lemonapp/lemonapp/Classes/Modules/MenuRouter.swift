//
//  MenuRouter.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import DrawerController
import Bond


final class MenuRouter: NSObject {
    
    fileprivate(set) weak var drawerController: DrawerController?
    
    var selectedMenuItem: Observable<MenuItem>
    var currentMenuItem: MenuItem? = nil
    
    let statusBarStyle = Observable(UIStatusBarStyle.lightContent)
    
    override init() {
        if DataProvider.sharedInstance.isAdminUser() {
            self.selectedMenuItem = Observable<MenuItem>(MenuItem.AdminDashboard)
        } else {
            self.selectedMenuItem = Observable<MenuItem>(MenuItem.UserDashboard)
        }
        super.init()
    }
    
    func showLanding(_ animated: Bool) {
        let menu = MenuViewController.fromNib()
        menu.router = self
        
        statusBarStyle.observeNext { [weak menu] _ in
            menu?.setNeedsStatusBarAppearanceUpdate()
        }
        
        let orderListNavigationController = UIViewController()
        
        let drawerController = DrawerController(centerViewController: orderListNavigationController, leftDrawerViewController: menu, rightDrawerViewController: nil)
        drawerController.maximumLeftDrawerWidth = 290
        drawerController.shouldStretchDrawer = false
        drawerController.showsShadows = false
        drawerController.openDrawerGestureModeMask = .all
        drawerController.closeDrawerGestureModeMask = .all
        drawerController.drawerVisualStateBlock = { drawerController, drawerSide, percentVisible in
            if percentVisible > 0.99 {
                self.statusBarStyle.value = .default
                UIApplication.shared.isStatusBarHidden = true
                drawerController.setNeedsStatusBarAppearanceUpdate()
                drawerController.centerViewController!.view.alpha = 0.5
            } else {
                self.statusBarStyle.value = drawerController.centerViewController?.preferredStatusBarStyle ?? .lightContent
                UIApplication.shared.isStatusBarHidden = false
                drawerController.setNeedsStatusBarAppearanceUpdate()
                drawerController.centerViewController!.view.alpha = 1
            }
        }
        
        
        let appDelegate = UIApplication.shared.delegate!
        let window = appDelegate.window!
        
        let prevVC = window?.rootViewController
        
        window?.rootViewController = drawerController
        
        self.drawerController = drawerController
        
        if DataProvider.sharedInstance.isAdminUser() {
            showScreenForMenuItem(.AdminDashboard)
        } else {
            showScreenForMenuItem(.UserDashboard)
        }

        selectedMenuItem.observeNext { [weak self] menuItem in
            self?.showScreenForMenuItem(menuItem)
        }
        
        if let prevView = (prevVC as? UINavigationController)?.topViewController?.view, animated {
            window?.addSubview(prevView)
            UIView.animate(withDuration: 0.5, animations: { [weak prevView] in
                prevView?.alpha = 0
            }, completion: { [weak prevView] _ in
                prevView?.removeFromSuperview()
            }) 
        }
    }
    
    
    func showOrdersFlow(_ completion: (() -> Void)? = nil ) {
        let orderList = UIStoryboard(storyboard: .Orders).instantiateInitialViewController()! as! UINavigationController
        let orderListViewController = orderList.topViewController! as! OrderListViewController
        orderListViewController.router = OrderListRouter(menuRouter: self)
        
        orderList.view.alpha = 0
        self.drawerController?.view.window?.addSubview(orderList.view)
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.drawerController?.centerViewController?.view.alpha = 0
            orderList.view.alpha = 1
        }, completion: { [weak self] _ in
            orderList.view.removeFromSuperview()
            self?.currentMenuItem = .UserDashboard
            self?.selectedMenuItem.value = .UserDashboard
            self?.drawerController?.setCenter(orderList, withCloseAnimation: true, completion: nil)
            completion?()
        }) 
    }
    
    func showDashboardAdmin() {
        let orderList = UIStoryboard(storyboard: .AdminOrders).instantiateInitialViewController() as!  UINavigationController
        let orderListViewController = orderList.topViewController as! AdminOrderListViewController
        orderListViewController.router = OrderListRouter(menuRouter: self)
        orderList.view.alpha = 0
        self.drawerController?.view.window?.addSubview(orderList.view)
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.drawerController?.centerViewController?.view.alpha = 0
            orderList.view.alpha = 1
        }, completion: { [weak self] _ in
            orderList.view.removeFromSuperview()
            self?.currentMenuItem = .AdminDashboard
            self?.selectedMenuItem.value = .AdminDashboard
            self?.drawerController?.setCenter(orderList, withCloseAnimation: true, completion: nil)
        }) 
    }
    
    
    func showNewOrderFlow() {
        if let drawerController = drawerController,
            let navController = drawerController.centerViewController as? UINavigationController {
            NewOrderRouter(menuRouter: self).showNewOrderFlowFromViewController(navController)
        } else {
            NewOrderRouter(menuRouter: self).showNewOrderFlowFromViewController(drawerController!)
        }
    }
    
    func showEditOrderFlow(_ editedOrder: Order, isAdminMode: Bool) {
        if let drawerController = drawerController,
            let navController = drawerController.centerViewController as? UINavigationController {
            NewOrderRouter(menuRouter: self).showNewOrderFlowFromViewController(navController, editedOrder: editedOrder, isAdminMode: isAdminMode)
        } else {
            NewOrderRouter(menuRouter: self).showNewOrderFlowFromViewController(drawerController!, editedOrder: editedOrder, isAdminMode: isAdminMode)
        }
    }
    
    func showOrderServicesFlow(_ order: Order) {
        if let drawerController = drawerController,
            let navController = drawerController.centerViewController as? UINavigationController {
            NewOrderRouter(menuRouter: self).showOrderServicesFlow(navController, order: order)
        } else {
            NewOrderRouter(menuRouter: self).showOrderServicesFlow(drawerController!, order: order)
        }
    }

    func showOrderReceiptFlow(_ order: Order) {
        if let drawerController = drawerController,
            let navController = drawerController.centerViewController as? UINavigationController {
            NewOrderRouter(menuRouter: self).showOrderReceiptFlow(navController, order: order)
        } else {
            NewOrderRouter(menuRouter: self).showOrderReceiptFlow(drawerController!, order: order)
        }
    }

    
    fileprivate func showScreenForMenuItem(_ menuItem: MenuItem) {
        if currentMenuItem != menuItem {
            DataProvider.sharedInstance.userWrapper?.refresh()
            drawerController?.openDrawerGestureModeMask = OpenDrawerGestureMode.all
            switch menuItem {
            case .Preferences:
                let viewController = PreferencesRouter(menuRouter: self).preferencesViewController()
                drawerController?.setCenter(viewController, withCloseAnimation: true, completion: nil)
                drawerController?.openDrawerGestureModeMask = OpenDrawerGestureMode.panningNavigationBar
                break
            case .UserDashboard:
                if let orderList = UIStoryboard(storyboard: .Orders).instantiateInitialViewController() as?  UINavigationController,
                    let orderListViewController = orderList.topViewController as? OrderListViewController {
                    orderListViewController.viewModel.isAdminMode = (menuItem == .AdminDashboard)
                    orderListViewController.router = OrderListRouter(menuRouter: self)
                    drawerController?.setCenter(orderList, withCloseAnimation: true, completion: nil)
                }
                break
            case .AdminDashboard:
                if let orderList = UIStoryboard(storyboard: .AdminOrders).instantiateInitialViewController() as?  UINavigationController,
                    let orderListViewController = orderList.topViewController as? AdminOrderListViewController {
                    orderListViewController.router = OrderListRouter(menuRouter: self)
                    drawerController?.setCenter(orderList, withCloseAnimation: true, completion: nil)
                }
                break;
            case .Settings:
                let settingsContainer = UIStoryboard(storyboard: .CommonContainer).instantiateInitialViewController()! as! CommonContainerViewController
                if let userWrapper = DataProvider.sharedInstance.userWrapper {
                    settingsContainer.viewModel = CommonContainerViewModel(userWrapper: userWrapper, screenIndetifier: .SettingsScreen, router: (SettingsRouter(menuRouter: self)))
                }
                drawerController?.setCenter(settingsContainer, withCloseAnimation: true, completion: nil)
                break
            case .Profile:
                
                if let profile = UIStoryboard(storyboard: .Profile).instantiateInitialViewController() as? ProfileViewController,
                    let userWrapper = DataProvider.sharedInstance.userWrapper {
                    profile.viewModel = ProfileViewModel(userWrapper: userWrapper, router: ProfileRouter(menuRouter: self))
                    
                    drawerController?.setCenter(profile, withCloseAnimation: true, completion: nil)
                }
                break
            case .Support:
                let support = UIStoryboard(storyboard: .Support).instantiateInitialViewController()!
                drawerController?.setCenter(support, withCloseAnimation: true, completion: nil)
                break
            case .Pricing:
                if let pricingNC = UIStoryboard(storyboard: .Pricing).instantiateInitialViewController(),
                    let pricing = (pricingNC as? UINavigationController)?.viewControllers.first as? PricingViewController {
                    pricing.router = PricingRouter(menuRouter: self)
                    drawerController?.setCenter(pricingNC, withCloseAnimation: true, completion: nil)
                }
                break
            case .CloudCloset:
                if let cloudClosetNC = UIStoryboard(storyboard: .CloudCloset).instantiateInitialViewController() as? YellowNavigationController,
                    let cloudClosetVC = cloudClosetNC.viewControllers.first as? CloudClosetViewController {
                    cloudClosetNC.barStyle.next(.black)
                    cloudClosetVC.viewModel = CloudClosetViewModel(router: CloudClosetRouter(menuRouter: self))
                    drawerController?.setCenter(cloudClosetNC, withCloseAnimation: true, completion: nil)
                }
                break
            case .Products:
                if let productNC = UIStoryboard(storyboard: .Product).instantiateInitialViewController(),
                    let product = (productNC as? UINavigationController)?.viewControllers.first as? ProductViewController {
                    product.router = ProductRouter(menuRouter: self)
                    drawerController?.setCenter(productNC, withCloseAnimation: true, completion: nil)
                }
                break
            case .Analytics, .Messages, .Contacts:
                return
            }
            currentMenuItem = menuItem
        } else {
            drawerController?.closeDrawer(animated: true, completion: nil)
        }
    }
}

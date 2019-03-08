//
//  ProductRouter.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/4/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation

final class ProductRouter: NSObject {
    
    fileprivate weak var menuRouter: MenuRouter?
    fileprivate weak var navigationController: UINavigationController?
    
    init(menuRouter: MenuRouter) {
        self.menuRouter = menuRouter
    }
    
    func showOrdersFlow() {
        menuRouter?.showDashboardAdmin()
    }
    
    func showEditServiceFlow(_ fromViewController: UIViewController, serviceToEdit: Service, department: Service) {
        let storyboard = UIStoryboard(storyboard: .OrderServicesAndReceipt)
        if let editServiceScreen = storyboard.instantiateViewControllerWithIdentifier(.NewService) as? NewServiceViewController {
            
            editServiceScreen.department = department
            editServiceScreen.newService = serviceToEdit
            editServiceScreen.isEditMode = true
            
            if let navController = fromViewController.navigationController {
                navController.pushViewController(editServiceScreen, animated: true)
                navigationController = navController
            } else {
                let newOrderFlow = TransparentNavigationController(rootViewController: editServiceScreen)
                newOrderFlow.viewControllers = [editServiceScreen]
                fromViewController.present(newOrderFlow, animated: true, completion: nil)
            }
        }
    }
    
    func showEditServiceCategoryFlow(_ fromViewController: UIViewController, departmentToEdit: Service) {
        let storyboard = UIStoryboard(storyboard: .OrderServicesAndReceipt)
        if let editServicesScreen = storyboard.instantiateViewControllerWithIdentifier(.NewServiceCategory) as? NewServiceCategoryViewController {
            
            editServicesScreen.department = departmentToEdit
            editServicesScreen.isEditMode = true
            
            if let navController = fromViewController.navigationController {
                navController.pushViewController(editServicesScreen, animated: true)
                navigationController = navController
            } else {
                let newOrderFlow = TransparentNavigationController(rootViewController: editServicesScreen)
                newOrderFlow.viewControllers = [editServicesScreen]
                fromViewController.present(newOrderFlow, animated: true, completion: nil)
            }
        }
    }
    
    func showNewDepartmentFlow(_ fromViewController: UIViewController) {
        let storyboard = UIStoryboard(storyboard: .OrderServicesAndReceipt)
        if let newServicesScreen = storyboard.instantiateViewControllerWithIdentifier(.NewServiceCategory) as? NewServiceCategoryViewController {
            
            if let navController = fromViewController.navigationController {
                navController.pushViewController(newServicesScreen, animated: true)
                navigationController = navController
            } else {
                let newOrderFlow = TransparentNavigationController(rootViewController: newServicesScreen)
                newOrderFlow.viewControllers = [newServicesScreen]
                fromViewController.present(newOrderFlow, animated: true, completion: nil)
            }
        }
    }
    
    func showNewServiceFlow(_ fromViewController: UIViewController, department: Service) {
        let storyboard = UIStoryboard(storyboard: .OrderServicesAndReceipt)
        if let newServiceScreen = storyboard.instantiateViewControllerWithIdentifier(.NewService) as? NewServiceViewController {
            
            newServiceScreen.department = department
            if let navController = fromViewController.navigationController {
                navController.pushViewController(newServiceScreen, animated: true)
                navigationController = navController
            } else {
                let newOrderFlow = TransparentNavigationController(rootViewController: newServiceScreen)
                newOrderFlow.viewControllers = [newServiceScreen]
                fromViewController.present(newOrderFlow, animated: true, completion: nil)
            }
        }
    }
}

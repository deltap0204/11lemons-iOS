//
//  NewOrderRouter.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit


final class NewOrderRouter: NSObject {
    
    fileprivate weak var menuRouter: MenuRouter?
    fileprivate weak var navigationController: UINavigationController?
    fileprivate var transition: TutorialOverlayTransition?    
    
    init(menuRouter: MenuRouter) {
        self.menuRouter = menuRouter
    }
    
    func suggestNotifications() {
        if !Config.ShouldRegisterForPushes {
            return
        }
        
        if let alert = DataProvider.sharedInstance.suggestNotificationsAlert() {
            
            if let navigation = navigationController as? YellowNavigationController {
                navigation.hideStatusBar.next(true)
            
                alert.completion = { turnOn in
                    if turnOn {
                        DataProvider.sharedInstance.registerForPushes()
                    }
                    DataProvider.sharedInstance.setDidShowNotifications()
                    alert.dismiss(animated: true, completion: nil)
                    navigation.hideStatusBar.next(false)
                }
                
                transition = TutorialOverlayTransition()
                alert.modalPresentationStyle = .overFullScreen
                alert.transitioningDelegate = transition
                
                menuRouter?.drawerController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func showNewOrderFlowFromViewController(_ fromViewController: UIViewController, editedOrder: Order? = nil, isAdminMode: Bool = false) {
        let storyboard = UIStoryboard(storyboard: .NewOrder)
        if let detailedOrderScreen = storyboard.instantiateViewControllerWithIdentifier(.DetailedOrderScreen) as? DetailedNewOrderViewController {
            
            detailedOrderScreen.router = self
            detailedOrderScreen.viewModel = DetailedNewOrderViewModel(editedOrder: editedOrder, isAdminMode: isAdminMode)
            
            if let navController = fromViewController as? UINavigationController {
                navController.pushViewController(detailedOrderScreen, animated: true)
                navigationController = navController
            } else {
                let newOrderFlow = TransparentNavigationController(rootViewController: detailedOrderScreen)
                newOrderFlow.viewControllers = [detailedOrderScreen]
                fromViewController.present(newOrderFlow, animated: true, completion: nil)
            }
        }
    }
    
    func showOrderServicesFlow(_ fromViewController: UIViewController, order: Order) {
        let storyboard = UIStoryboard(storyboard: .OrderServicesAndReceipt)
        if let orderServicesScreen = storyboard.instantiateViewControllerWithIdentifier(.OrderServices) as? AddOrderDetailsViewController {
            
            orderServicesScreen.router = self
            orderServicesScreen.order = order
            
            if let navController = fromViewController as? UINavigationController {
                navController.pushViewController(orderServicesScreen, animated: true)
                navigationController = navController
            } else if let navController = fromViewController.navigationController {
                navController.pushViewController(orderServicesScreen, animated: true)
                navigationController = navController
            } else {
                let newOrderFlow = TransparentNavigationController(rootViewController: orderServicesScreen)
                newOrderFlow.viewControllers = [orderServicesScreen]
                fromViewController.present(newOrderFlow, animated: true, completion: nil)
            }
        }
    }
    
    func showNewServiceCategoryFlow(_ fromViewController: UIViewController, orderDetail: OrderDetail) {
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
    
    func showNewServiceFlow(_ fromViewController: UIViewController, orderDetail: OrderDetail) {
        let storyboard = UIStoryboard(storyboard: .OrderServicesAndReceipt)
        if let newServiceScreen = storyboard.instantiateViewControllerWithIdentifier(.NewService) as? NewServiceViewController {
            
            
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
    
    func showEditServiceFlow(_ fromViewController: UIViewController, serviceToEdit: Service, serviceCategory: Service) {
        let storyboard = UIStoryboard(storyboard: .OrderServicesAndReceipt)
        if let editServiceScreen = storyboard.instantiateViewControllerWithIdentifier(.NewService) as? NewServiceViewController {
            
            editServiceScreen.department = serviceCategory
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
    
    func showNewAttributeCategoryFlow(_ fromViewController: UIViewController) {
        let storyboard = UIStoryboard(storyboard: .OrderServicesAndReceipt)
        if let newAttributeScreen = storyboard.instantiateViewControllerWithIdentifier(.NewAttributeCategory) as? NewAttributeCategoryViewController {
            
            newAttributeScreen.router = self
            
            if let navController = fromViewController.navigationController {
                navController.pushViewController(newAttributeScreen, animated: true)
                navigationController = navController
            } else {
                let newOrderFlow = YellowNavigationController(rootViewController: newAttributeScreen)
                newOrderFlow.viewControllers = [newAttributeScreen]
                fromViewController.present(newOrderFlow, animated: true, completion: nil)
            }
        }
    }
    
    func showEditAttributeCategoryFlow(_ fromViewController: UIViewController, attributeCategoryToEdit: Category) {
        let storyboard = UIStoryboard(storyboard: .OrderServicesAndReceipt)
        if let editAttributeScreen = storyboard.instantiateViewControllerWithIdentifier(.NewAttributeCategory) as? NewAttributeCategoryViewController {
            
            editAttributeScreen.router = self
            editAttributeScreen.isEditMode = true
            editAttributeScreen.attributeCategory = attributeCategoryToEdit
            
            if let navController = fromViewController.navigationController {
                navController.pushViewController(editAttributeScreen, animated: true)
                navigationController = navController
            } else {
                let newOrderFlow = YellowNavigationController(rootViewController: editAttributeScreen)
                newOrderFlow.viewControllers = [editAttributeScreen]
                fromViewController.present(newOrderFlow, animated: true, completion: nil)
            }
        }
    }
    
    func showGetAttributeCategoryFlow(_ fromViewController: UIViewController, orderDetail: OrderDetail, onPickCategory: @escaping ((_ category: Category) -> ())) {
        let storyboard = UIStoryboard(storyboard: .OrderServicesAndReceipt)
        if let pickAttributeScreen = storyboard.instantiateViewControllerWithIdentifier(.PickAttributeCategory) as? PickAttributeCategoryViewController {
            
            pickAttributeScreen.pickedCategory = onPickCategory
            pickAttributeScreen.router = self
            pickAttributeScreen.orderDetail = orderDetail
            
            if let navController = fromViewController.navigationController {
                navController.pushViewController(pickAttributeScreen, animated: true)
                navigationController = navController
            } else {
                let newOrderFlow = YellowNavigationController(rootViewController: pickAttributeScreen)
                newOrderFlow.viewControllers = [pickAttributeScreen]
                fromViewController.present(newOrderFlow, animated: true, completion: nil)
            }
        }
    }
    
    func showNewAttributeFlow(_ fromViewController: UIViewController, attributeCategory: Category) {
        let storyboard = UIStoryboard(storyboard: .OrderServicesAndReceipt)
        if let newAttributeScreen = storyboard.instantiateViewControllerWithIdentifier(.NewAttribute) as? NewAttributeViewController {
            
            newAttributeScreen.router = self
            newAttributeScreen.category = attributeCategory
            
            if let navController = fromViewController.navigationController {
                navController.pushViewController(newAttributeScreen, animated: true)
                navigationController = navController
            } else {
                let newOrderFlow = YellowNavigationController(rootViewController: newAttributeScreen)
                newOrderFlow.viewControllers = [newAttributeScreen]
                fromViewController.present(newOrderFlow, animated: true, completion: nil)
            }
        }
    }
    
    func showEditAttributeFlow(_ fromViewController: UIViewController, attributeToEdit: Attribute) {
        let storyboard = UIStoryboard(storyboard: .OrderServicesAndReceipt)
        if let editAttributeScreen = storyboard.instantiateViewControllerWithIdentifier(.NewAttribute) as? NewAttributeViewController {
            
            editAttributeScreen.router = self
            editAttributeScreen.attribute = attributeToEdit
            editAttributeScreen.isEditMode = true
            
            if let navController = fromViewController.navigationController {
                navController.pushViewController(editAttributeScreen, animated: true)
                navigationController = navController
            } else {
                let newOrderFlow = YellowNavigationController(rootViewController: editAttributeScreen)
                newOrderFlow.viewControllers = [editAttributeScreen]
                fromViewController.present(newOrderFlow, animated: true, completion: nil)
            }
        }
    }
    
    func showPreferencesFromViewController(_ fromViewController: UIViewController) {
        fromViewController.dismiss(animated: true) {
            self.menuRouter?.selectedMenuItem.value = .Preferences
        }
    }
    
    func showProfileFromViewController(_ fromViewController: UIViewController) {
        fromViewController.dismiss(animated: true) {
            self.menuRouter?.selectedMenuItem.value = .Profile
        }
    }
    
    func showOrderReceiptFlow(_ fromViewController: UIViewController, order: Order) {
        let storyboard = UIStoryboard(storyboard: .OrderServicesAndReceipt)
        if let receiptScreen = storyboard.instantiateViewControllerWithIdentifier(.Receipt) as? ReceiptViewController {
            
            receiptScreen.order = order
            receiptScreen.isAdmin = true
            if let navController = fromViewController as? UINavigationController {
                navController.pushViewController(receiptScreen, animated: true)
                navigationController = navController
            } else if let navController = fromViewController.navigationController {
                navController.pushViewController(receiptScreen, animated: true)
                navigationController = navController
            } else {
                let newOrderFlow = YellowNavigationController(rootViewController: receiptScreen)
                newOrderFlow.viewControllers = [receiptScreen]
                fromViewController.present(newOrderFlow, animated: true, completion: nil)
            }
        }
    }
}

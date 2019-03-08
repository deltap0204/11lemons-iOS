//
//  PreferencesRouter.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


final class PreferencesRouter {
    
    weak var menuRouter: MenuRouter?
    fileprivate var transition: TutorialOverlayTransition?
    fileprivate let DidShowSchedulePickupTutorialKey = "DidShowSchedulePickupTutorialKey"
    
    init(menuRouter: MenuRouter) {
        self.menuRouter = menuRouter
    }
    
    func preferencesViewController() -> UIViewController {
        let preferencesNavigation = UIStoryboard(storyboard: .Preferences).instantiateInitialViewController()! as! UINavigationController
        let preferences = preferencesNavigation.topViewController as! PreferencesViewController
        if let userWrapper = DataProvider.sharedInstance.userWrapper {
            preferences.viewModel = PreferencesViewModel(userWrapper: userWrapper)
        }
        preferences.router = self
        return preferencesNavigation
    }
    
    
    func done() {
        menuRouter?.showOrdersFlow {
            if Preferences().scheduledFrequency == 0 {
                return
            }
            
            let defaults = UserDefaults.standard
            if let userId = DataProvider.sharedInstance.userWrapper?.id, defaults.bool(forKey: self.DidShowSchedulePickupTutorialKey + "\(userId)") {
                return
            }
            
            let overlay = ScheduledPickupsOverlay.fromNib()
            overlay.completion = {
                overlay.dismiss(animated: true, completion: nil)
                self.showPushSuggestion()
            }
            self.transition = TutorialOverlayTransition()
            overlay.modalPresentationStyle = .overFullScreen
            overlay.transitioningDelegate = self.transition
            
            self.setDidShowScheduledPickupTutorial()
            self.menuRouter?.drawerController?.present(overlay, animated: true, completion: nil)
        }
    }
    
    
    fileprivate func setDidShowScheduledPickupTutorial() {
        if let userId = DataProvider.sharedInstance.userWrapper?.id {
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: DidShowSchedulePickupTutorialKey + "\(userId)")
            defaults.synchronize()
        }
    }
    
    
    fileprivate func showPushSuggestion() {
        if let alert = DataProvider.sharedInstance.suggestNotificationsAlert() {
            
            if let navigation = self.menuRouter?.drawerController?.centerViewController as? YellowNavigationController {
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
}

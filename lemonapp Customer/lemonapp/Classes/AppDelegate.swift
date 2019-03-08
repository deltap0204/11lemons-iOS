//
//  AppDelegate.swift
//  lemonapp
//
//  Created by mac-190-mini on 12/23/15.
//  Copyright © 2015 11lemons. All rights reserved.
//

import UIKit
import CoreData
import KeychainAccess
import Reachability
import Fabric
import Crashlytics
import IQKeyboardManagerSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    var reachability : Reachability? = Reachability.forInternetConnection()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        
        UIApplication.shared.statusBarStyle = .lightContent

        customizeUI()
        //LemonCoreDataManager
        
        IQKeyboardManager.sharedManager().enable = true

        
        initLemonCoreDataManager {
            if DataProvider.sharedInstance.isUserLogged {
                _ = LemonAPI.restore()
                let authRouter = AuthRouter()
                authRouter.openHome(false)
                DataProvider.sharedInstance.restoreData() { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.setupReachability()
                    strongSelf.refreshData()
                    strongSelf.checkAPIVersion()
                }
            } else {
        
                let initialViewController = UIStoryboard(storyboard: .Auth).instantiateInitialViewController()
                UIApplication.shared.keyWindow?.rootViewController = initialViewController
                
                self.setupReachability()
                self.checkAPIVersion()
            }
    
        }
        return true
    }
    
    fileprivate func checkAPIVersion() {
        
        _ = LemonAPI.getServerApiVersion().request().observeNext { [weak self] (resolver : EventResolver<String>) in
            let version = (Int((try? resolver()) ?? "0")) ?? Config.APIVersion
            if Config.APIVersion < version {
                self?.window?.rootViewController?.showAlert(nil, message: "Please, update the app", positiveButton: "OK", positiveAction: { _ in
                    UIApplication.shared.open(NSURL(string: "itms://itunes.com/apps/11lemons")! as URL, options: [:], completionHandler: nil)
                    exit(0)
                })
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("11lemons: did register device on APNS with token: \(deviceToken.description)")
        DataProvider.sharedInstance.rememberDevicePushNotificationToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("11lemons: failed to register device of APNS for pushes \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("11lemons: push notification came")
        if let aps = userInfo["aps"] as? [AnyHashable : Any] {
            if let message = aps["alert"] as? String {
                print("11lemons: message from push is: \(message)")
                let alert = UIAlertController(title: "11Lemons", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                    alert.dismiss(animated: true, completion: nil)
                }))
                window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func setupReachability() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        reachability?.startNotifier()
        
    }
    
    @objc func reachabilityChanged(note: Notification) {
        DispatchQueue.main.async {
            let reachability = note.object as! Reachability
            
            if reachability.isReachable() && DataProvider.sharedInstance.isUserLogged {
                self.refreshData()
                self.checkAPIVersion()
            }
        }
    }
        
    
    func applicationWillResignActive(_ application: UIApplication) {
        reachability?.stopNotifier()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        reachability?.startNotifier()
    }
    
    fileprivate func refreshData() {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            DataProvider.sharedInstance.getInitialData()
//            DataProvider.sharedInstance.refreshData()
//            DataProvider.sharedInstance.refreshUserOrders()
//            DataProvider.sharedInstance.refreshAdminOrders()
        }
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        LemonCoreDataManager.saveChanges()
    }
    
    fileprivate func customizeUI() {
        let sliderAppearance = UISlider.appearance()
        sliderAppearance.setThumbImage(UIImage(assetIdentifier: UIImage.AssetIdentifier.Knob), for: UIControlState())
        sliderAppearance.setThumbImage(UIImage(assetIdentifier: UIImage.AssetIdentifier.KnobWhite), for:[UIControlState.selected, UIControlState.disabled])
        sliderAppearance.setThumbImage(UIImage(assetIdentifier: UIImage.AssetIdentifier.KnobWhite), for:[UIControlState.selected])
        sliderAppearance.setMinimumTrackImage(UIImage(assetIdentifier: UIImage.AssetIdentifier.MinBg), for: UIControlState())
        sliderAppearance.setMaximumTrackImage(UIImage(assetIdentifier: UIImage.AssetIdentifier.MaxBg), for: UIControlState())
    }
}


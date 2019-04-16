//
//  DataProvider + PushNotification.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 20/02/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//

import Foundation
import UserNotifications

extension DataProvider {
    func registerForPushes() {
        if Config.ShouldRegisterForPushes {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func rememberDevicePushNotificationToken(_ deviceToken: Data) {
        let hub = SBNotificationHub(connectionString: Config.HubListenAccess, notificationHubPath: Config.HubName)
        let userId = _ = LemonAPI.userId ?? 0
        
        //let tagSet = Set<NSObject>(arrayLiteral: "\(userId)")
        let tagSet = Set(arrayLiteral: "\(userId)")
        
        print(tagSet)
        print("11lemons: will register device token for userId:\(userId)")
        hub?.registerNative(withDeviceToken: deviceToken, tags: tagSet) { [weak self] error in
            if let error = error {
                print("11lemons: error in registering on 11lemons backend \(error.localizedDescription)")
            } else {
                print("11lemons: registered on 11lemons backend")
                print("11lemons: will try to enable pushes in user settings")
                if let changedUser = self?.userWrapper?.changedUser {
                    
                    changedUser.settings.pushEnabled = true
                    _ = LemonAPI.editProfile(user: changedUser).request().observeNext { (resolver: EventResolver<User>) in
                        do {
                            let user = try resolver()
                            self?.userWrapper?.saveChanges()
                            user.settings.save()
                            print("11lemons: enabled pushes in user settings")
                        } catch {
                            self?.userWrapper?.refresh()
                            print("11lemons: failed to enable pushes in user settings")
                        }
                    }
                }
            }
        }
    }

    func suggestNotificationsAlert() -> SuggestNotificationViewController? {
        let defaults = UserDefaults.standard
        if let userId = userWrapper?.id, defaults.bool(forKey: DidSuggestNotificationsKey + "\(userId)") {
            return nil
        }
        
        let viewController = SuggestNotificationViewController.fromNib()
        return viewController
    }
    
    func setDidShowNotifications() {
        if let userId = userWrapper?.id {
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: DidSuggestNotificationsKey + "\(userId)")
            defaults.synchronize()
        }
    }
}

//
//  SettingsViewModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit

final class SettingsViewModel: ViewModel {
    
    var pushEnabled = Observable<Bool>(false)
    var mailEnabled = Observable<Bool>(false)
    var messageEnabled = Observable<Bool>(false)
    
    var cloudClosetEnabled = Observable(true)
    
    var pushSelected = Observable<Bool>(false)
    var mailSelected = Observable<Bool>(false)
    var messageSelected = Observable<Bool>(false)
    
    let userViewModel: UserViewModel
    
    fileprivate let userWrapper: UserWrapper
    var changedUser: User
    let settingsRouter: SettingsRouter?
    
    init(userWrapper: UserWrapper, settingsRouter: SettingsRouter?) {
        self.settingsRouter = settingsRouter
        self.userWrapper = userWrapper
        self.changedUser = userWrapper.changedUser
        self.userViewModel = UserViewModel(userWrapper: userWrapper)
        
        cloudClosetEnabled.value = changedUser.settings.cloudClosetEnabled
        pushEnabled.value = changedUser.settings.pushEnabled
        mailEnabled.value = changedUser.settings.mailEnabled
        messageEnabled.value = changedUser.settings.messageEnabled
        
        cloudClosetEnabled.observeNext { [weak self] in
            self?.changedUser.settings.cloudClosetEnabled = $0
        }
        
        pushEnabled.observeNext { [weak self] enabled in
            self?.changedUser.settings.pushEnabled = enabled
            if enabled {
                DataProvider.sharedInstance.registerForPushes()
            }
        }
        
        mailEnabled.observeNext { [weak self] enabled in
            self?.changedUser.settings.mailEnabled = enabled
        }
        
        messageEnabled.observeNext { [weak self] enabled in
            self?.changedUser.settings.messageEnabled = enabled
        }
    }
    
    func goToOrders() {
        settingsRouter?.showOrders()
    }
    
    func refresh() {
//        userWrapper.refresh()
//        cloudClosetEnabled.value = changedUser.settings.cloudClosetEnabled
//        pushEnabled.value = changedUser.settings.pushEnabled
//        mailEnabled.value = changedUser.settings.mailEnabled
//        messageEnabled.value = changedUser.settings.messageEnabled
    }
    
    
    var saveRequest: Action<UserResolver> {
        return Action { [weak self] in
            return Signal { sink in
                if let changedUser = self?.changedUser,
                let userWrapper = self?.userWrapper {
                    _ = LemonAPI.editProfile(user: changedUser).request().observeNext { (userResolver: UserResolver) in
                        do {
                            let user = try userResolver()
                            userWrapper.changedUser.settings.sync(user.settings)
                            userWrapper.saveChanges()
                            user.settings.save()                            
                            sink.completed(with: { return user })
                        } catch let error {
                            sink.completed(with: { throw error })
                        }
                    }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
}

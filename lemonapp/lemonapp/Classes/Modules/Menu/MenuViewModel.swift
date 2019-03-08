//
//  MenuViewModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond


final class MenuViewModel {
    static let AdminModeItems: [MenuItem] = [.AdminDashboard, .Contacts, .CloudCloset, .Messages, .Products, .Analytics, .Settings]
    static let UserModeItems: [MenuItem] = [.UserDashboard, .CloudCloset, .Preferences, .Settings, .Pricing, .Support]
    
    var menuItems: MutableObservableArray<MenuItem>
    var selectedMenuItem: Observable<MenuItem>
    
    var isAdminModeSwitcherHidden = Observable<Bool>(false)
    var isAdminMode: Observable<Bool>
    
    let menuHeaderViewModel: Observable<UserViewModel?> = Observable(nil)
    
    init () {
        if DataProvider.sharedInstance.isAdminUser() {
            self.selectedMenuItem = Observable<MenuItem>(.AdminDashboard)
            self.menuItems = MutableObservableArray<MenuItem>(MenuViewModel.AdminModeItems)
            self.isAdminMode = Observable<Bool>(true)
        } else {
            self.selectedMenuItem = Observable<MenuItem>(.UserDashboard)
            self.menuItems = MutableObservableArray<MenuItem>(MenuViewModel.UserModeItems)
            self.isAdminMode = Observable<Bool>(false)
        }
        DataProvider.sharedInstance.userWrapperObserver.observeNext { [weak menuHeaderViewModel] in
            if let userWrapper = $0 {
                menuHeaderViewModel?.value = UserViewModel(userWrapper:userWrapper)
                userWrapper.settingsDidChange.observeNext { [weak self, weak userWrapper] in
                    if let cloudClosetEnabled = userWrapper?.changedUser.settings.cloudClosetEnabled, let strongSelf = self {
                        if let index = strongSelf.menuItems.array.index(of: .CloudCloset), !cloudClosetEnabled {
                            strongSelf.menuItems.remove(at: index)
                        } else if cloudClosetEnabled && !strongSelf.menuItems.array.contains(.CloudCloset) {
                            strongSelf.menuItems.insert(.CloudCloset, at: strongSelf.isAdminMode.value ? 2 : 1)
                        }
                    }
                  self?.isAdminModeSwitcherHidden.value = !(userWrapper?.changedUser.isAdmin ?? false)
                }
            } else {
                menuHeaderViewModel?.value = nil
            }
        }
        
        isAdminMode.observeNext { [weak self] (isAdminMode) in
            if let strongSelf = self {
                strongSelf.menuItems.removeAll()
                strongSelf.menuItems.insert(contentsOf: isAdminMode ? MenuViewModel.AdminModeItems : MenuViewModel.UserModeItems, at: 0)
                DataProvider.sharedInstance.userWrapperObserver.next(DataProvider.sharedInstance.userWrapper)
                strongSelf.selectedMenuItem.value = strongSelf.menuItems[0]
            }
        }
    }
    
    func selectMenuItem(_ item: MenuItem) {
        selectedMenuItem.value = item
    }
    
    func indexOfSelectedItem() -> Int {
        return menuItems.array.index(of: selectedMenuItem.value)!
    }
}

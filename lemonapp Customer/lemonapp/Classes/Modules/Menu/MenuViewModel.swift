//
//  MenuViewModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond


final class MenuViewModel {
    static let UserModeItems: [MenuItem] = [.UserDashboard, .CloudCloset, .Preferences, .Settings, .Pricing, .Support]
    
    var menuItems: MutableObservableArray<MenuItem>
    var selectedMenuItem: Observable<MenuItem>
    
    let menuHeaderViewModel: Observable<UserViewModel?> = Observable(nil)
    
    init () {
        self.selectedMenuItem = Observable<MenuItem>(.UserDashboard)
        self.menuItems = MutableObservableArray<MenuItem>(MenuViewModel.UserModeItems)
        DataProvider.sharedInstance.userWrapperObserver.observeNext { [weak menuHeaderViewModel] in
            if let userWrapper = $0 {
                menuHeaderViewModel?.value = UserViewModel(userWrapper:userWrapper)
                userWrapper.settingsDidChange.observeNext { [weak self, weak userWrapper] in
                    if let cloudClosetEnabled = userWrapper?.changedUser.settings.cloudClosetEnabled, let strongSelf = self {
                        if let index = strongSelf.menuItems.array.index(of: .CloudCloset), !cloudClosetEnabled {
                            strongSelf.menuItems.remove(at: index)
                        } else if cloudClosetEnabled && !strongSelf.menuItems.array.contains(.CloudCloset) {
                            strongSelf.menuItems.insert(.CloudCloset, at: 1)
                        }
                    }
                }
            } else {
                menuHeaderViewModel?.value = nil
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

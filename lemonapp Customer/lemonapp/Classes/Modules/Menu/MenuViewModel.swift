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
    
    init () {
        self.selectedMenuItem = Observable<MenuItem>(.UserDashboard)
        self.menuItems = MutableObservableArray<MenuItem>(MenuViewModel.UserModeItems)
    }
    
    func selectMenuItem(_ item: MenuItem) {
        selectedMenuItem.value = item
    }
    
    func indexOfSelectedItem() -> Int {
        return menuItems.array.index(of: selectedMenuItem.value)!
    }
}

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
    
    var menuItems: MutableObservableArray<MenuItem>
    var selectedMenuItem: Observable<MenuItem>
    
    init() {
        self.selectedMenuItem = Observable<MenuItem>(.AdminDashboard)
        self.menuItems = MutableObservableArray<MenuItem>(MenuViewModel.AdminModeItems)
        
       
        
        self.menuItems.removeAll()
        self.menuItems.insert(contentsOf:  MenuViewModel.AdminModeItems, at: 0)
        DataProvider.sharedInstance.userWrapperObserver.next(DataProvider.sharedInstance.userWrapper)
        self.selectedMenuItem.value = self.menuItems[0]
    }
    
    func selectMenuItem(_ item: MenuItem) {
        selectedMenuItem.value = item
    }
    
    func indexOfSelectedItem() -> Int {
        return menuItems.array.index(of: selectedMenuItem.value)!
    }
}


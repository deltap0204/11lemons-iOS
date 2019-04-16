//
//  SoftnerPreferenceRowViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/17/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

class SoftnerPreferenceRowViewModel: PreferenceRowViewModel, PreferenceRowUser {
    
    func getPreferenceName() -> String {
        return "Fabric Softener"
    }
    
    override func getValue() -> String {
        return order.softener.rawValue
    }
    
    func changeValue(_ newOption: Any) {
        guard let option = newOption as? Softener else { return }
        
        order.softener = option
        if let changedUser = changedUser {
            changedUser.preferences.softener = option
            updateUserPreferences(changedUser.preferences)
        }
        
        delegate?.changeOrderDetailToAdd(order)
        updateOrder()
    }
    
    override func getAlert() -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: "Update Fabric Softener Preference for \(getUserNameCreator()):", preferredStyle: .actionSheet)
        let downyAction = UIAlertAction(title: "Downy", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.changeValue(Softener.Downy)
            strongSelf.valueSelected.value = Softener.Downy.rawValue
        }
        actionSheet.addAction(downyAction)
        
        let noneAction = UIAlertAction(title: "None", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.changeValue(Softener.None)
            strongSelf.valueSelected.value = Softener.None.rawValue
        }
        actionSheet.addAction(noneAction)
        
        let cancelAciton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAciton)
        return actionSheet
    }
}

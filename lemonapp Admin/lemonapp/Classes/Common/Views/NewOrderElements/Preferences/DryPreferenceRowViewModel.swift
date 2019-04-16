//
//  DryPreferenceRowViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/17/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

class DryPreferenceRowViewModel: PreferenceRowViewModel, PreferenceRowUser {
    
    func getPreferenceName() -> String {
        return "Dryer Sheets"
    }
    
    override func getValue() -> String {
        return order.dryer.rawValue
    }
    
    func changeValue(_ newOption: Any) {
        guard let option = newOption as? Dryer else { return }
        
        order.dryer = option
        if let changedUser = changedUser {
            changedUser.preferences.dryer = option
            updateUserPreferences(changedUser.preferences)
        }
        
        delegate?.changeOrderDetailToAdd(order)
        updateOrder()
    }
    
    override func getAlert() -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: "Update Dryer Sheet Preference for \(getUserNameCreator()):", preferredStyle: .actionSheet)
        let bounceAction = UIAlertAction(title: "Bounce", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.changeValue(Dryer.Bounce)
            strongSelf.valueSelected.value = Dryer.Bounce.rawValue
        }
        actionSheet.addAction(bounceAction)
        
        let noneAction = UIAlertAction(title: "None", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.changeValue(Dryer.None)
            strongSelf.valueSelected.value = Dryer.None.rawValue
        }
        actionSheet.addAction(noneAction)
        
        let cancelAciton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAciton)
        return actionSheet
    }
}

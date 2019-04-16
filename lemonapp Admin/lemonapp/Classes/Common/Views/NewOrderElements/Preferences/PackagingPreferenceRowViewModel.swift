//
//  PackagingPreferenceRowViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/17/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

class PackagingPreferenceRowViewModel: PreferenceRowViewModel, PreferenceRowUser {
    
    func getPreferenceName() -> String {
        return "Packaging"
    }
    
    override func getValue() -> String {
        return order.shirt.rawValue
    }
    
    func changeValue(_ newOption: Any) {
        guard let option = newOption as? Shirt else { return }
        
        order.shirt = option
        if let changedUser = changedUser {
            changedUser.preferences.shirts = option
            updateUserPreferences(changedUser.preferences)
        }
        delegate?.changeOrderDetailToAdd(order)
        updateOrder()
    }
    
    override func getAlert() -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: "Update Packaging Preference for \(getUserNameCreator()):", preferredStyle: .actionSheet)
        let hangerAction = UIAlertAction(title: "Hanger", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.changeValue(Shirt.Hanger)
            strongSelf.valueSelected.value = Shirt.Hanger.rawValue
        }
        actionSheet.addAction(hangerAction)
        
        let foldedAction = UIAlertAction(title: "Folded", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.changeValue(Shirt.Folded)
            strongSelf.valueSelected.value = Shirt.Folded.rawValue
        }
        actionSheet.addAction(foldedAction)
        
        let cancelAciton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAciton)
        return actionSheet
    }
}

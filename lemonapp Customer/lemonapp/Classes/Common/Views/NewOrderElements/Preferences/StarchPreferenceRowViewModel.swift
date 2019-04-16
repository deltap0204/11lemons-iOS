//
//  StarchPreferenceRowViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/17/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

class StarchPreferenceRowViewModel: PreferenceRowViewModel, PreferenceRowUser {
    
    func getPreferenceName() -> String {
        return "Starch"
    }
    
    override func getValue() -> String {
        return order.starch.rawValue
    }
    
    func changeValue(_ newOption: Any) {
        guard let option = newOption as? Starch else { return }
    //TODO: we are waiting for the BE implementation
        order.starch = option
//        if let changedUser = changedUser {
//            changedUser.preferences.starch = option
//            updateUserPreferences(changedUser.preferences)
//        }
        
        delegate?.changeOrderDetailToAdd(order)
//        updateOrder()
    }
    
    override func getAlert() -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: "Update Starch Preference for \(getUserNameCreator()):", preferredStyle: .actionSheet)
        let heavyAction = UIAlertAction(title: "Heavy", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.changeValue(Starch.Heavy)
            strongSelf.valueSelected.value = Starch.Heavy.rawValue
        }
        actionSheet.addAction(heavyAction)
        
        let mediumAction = UIAlertAction(title: "Medium", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.changeValue(Starch.Medium)
            strongSelf.valueSelected.value = Starch.Medium.rawValue
        }
        actionSheet.addAction(mediumAction)
        
        let lightAction = UIAlertAction(title: "Light", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.changeValue(Starch.Light)
            strongSelf.valueSelected.value = Starch.Light.rawValue
        }
        actionSheet.addAction(lightAction)
        
        let noneAction = UIAlertAction(title: "None", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.changeValue(Starch.None)
            strongSelf.valueSelected.value = Starch.None.rawValue
        }
        actionSheet.addAction(noneAction)
        
        let cancelAciton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAciton)
        return actionSheet
    }
}

//
//  DetergentPreferenceRow.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/17/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation
import Bond

class DetergentPreferenceRowViewModel: PreferenceRowViewModel, PreferenceRowUser {
    
    func getPreferenceName() -> String {
        return "Detergent"
    }

    override func getValue() -> String {
        var detergent = ""
        if order.detergent == Detergent.MountainSpring {
            detergent = "Mountain Spring"
        } else {
            detergent = order.detergent == Detergent.FreeNGentle ? "Free & Gentle" : order.detergent.rawValue
        }
        
        return detergent
    }
    
    func changeValue(_ newOption: Any) {
        guard let option = newOption as? Detergent else { return }
        
        order.detergent = option
        if let changedUser = changedUser {
            changedUser.preferences.detergent = option
            updateUserPreferences(changedUser.preferences)
        }
        
        delegate?.changeOrderDetailToAdd(order)
        updateOrder()
    }

    override func getAlert() -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: "Update Detergent Preference for \(getUserNameCreator()):", preferredStyle: .actionSheet)
        let originalAction = UIAlertAction(title: "Original", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.changeValue(Detergent.Original)
            strongSelf.valueSelected.value = Detergent.Original.rawValue
        }
        actionSheet.addAction(originalAction)
        
        let mountainSpringAction = UIAlertAction(title: "Mountain Spring", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.changeValue(Detergent.MountainSpring)
            strongSelf.valueSelected.value = "Mountain Spring"
        }
        actionSheet.addAction(mountainSpringAction)
        
        let lavenderAction = UIAlertAction(title: "Lavender", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.changeValue(Detergent.Lavender)
            strongSelf.valueSelected.value = Detergent.Lavender.rawValue
        }
        actionSheet.addAction(lavenderAction)
        
        let gentleAction = UIAlertAction(title: "Free & Gentle", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.changeValue(Detergent.FreeNGentle)
            strongSelf.valueSelected.value = "Free & Gentle"
        }
        actionSheet.addAction(gentleAction)
        
        let cancelAciton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAciton)
        
        return actionSheet
    }
}

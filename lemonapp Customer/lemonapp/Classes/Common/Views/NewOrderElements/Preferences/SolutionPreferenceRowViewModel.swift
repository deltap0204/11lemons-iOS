//
//  SolutionPreferenceRowViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/17/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

class SolutionPreferenceRowViewModel: PreferenceRowViewModel, PreferenceRowUser {
    
    func getPreferenceName() -> String {
        return "Solution"
    }
    
    override func getValue() -> String {
        return "Organic"
    }
    
    func changeValue(_ newOption: Any) {
    }
    
    override func getAlert() -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: "Update Starch Preference for \(getUserNameCreator()):", preferredStyle: .actionSheet)
        let heavyAction = UIAlertAction(title: "Organic", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.changeValue("Organic")
            strongSelf.valueSelected.value = "Organic"
        }
        actionSheet.addAction(heavyAction)
        
        let mediumAction = UIAlertAction(title: "Synthetic", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.changeValue(Starch.Medium)
            strongSelf.valueSelected.value = "Synthetic"
        }
        actionSheet.addAction(mediumAction)
        
        let noneAction = UIAlertAction(title: "None", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.changeValue(Starch.None)
            strongSelf.valueSelected.value = "None"
        }
        actionSheet.addAction(noneAction)
        
        let cancelAciton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAciton)
        return actionSheet
    }
}

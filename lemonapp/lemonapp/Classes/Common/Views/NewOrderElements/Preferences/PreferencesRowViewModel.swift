//
//  PreferencesRowViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/20/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

class PreferencesRowViewModel {
    let HeaderHeight = CGFloat(58)
    let rowViewModels: [PreferenceRowUser]
    
    init(rowViewModels: [PreferenceRowUser]) {
        self.rowViewModels = rowViewModels
    }
    
    func getRowsHeight() -> CGFloat {
        var rowsHeight = CGFloat(0)
        rowViewModels.forEach { rowVM in
            rowsHeight = rowsHeight + rowVM.getHeight()
        }
        
        return HeaderHeight + rowsHeight
    }
    
}
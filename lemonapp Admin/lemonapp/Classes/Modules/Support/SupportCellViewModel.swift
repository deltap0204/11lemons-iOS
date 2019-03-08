//
//  SupportCellViewModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


final class SupportCellViewModel {

    var supportType: SupportType
    var title = ""
    var value = ""
    
    var accessoryHidden: Bool {
        return supportType.isAction
    }
    
    var valueHidden: Bool {
        return !supportType.isAction
    }
    
    init(supportType: SupportType, title: String, value: String = "") {
        self.supportType = supportType
        self.title = title
        self.value = value
    }
}
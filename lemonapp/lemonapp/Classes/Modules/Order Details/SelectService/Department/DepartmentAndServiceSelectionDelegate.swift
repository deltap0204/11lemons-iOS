//
//  DepartmentAndServiceSelectionDelegate.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 12/12/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation

protocol  DepartmentAndServiceSelectionDelegate: class {
    func finalSelection(_ departments: [Service])
}

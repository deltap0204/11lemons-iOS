//
//  ServiceSelectionDelegate.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 12/12/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation

protocol  ServiceSelectionDelegate: class {
    func finalSelection(_ department: Service, services: [Service])
}

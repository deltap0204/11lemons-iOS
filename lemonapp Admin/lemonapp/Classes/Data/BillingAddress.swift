//
//  BillingAddress.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


struct BillingAddress {
    var address: String = ""
    var city: String = ""
    var state: String = ""
    var zip: String = ""
    
    init(address: String, city: String, state: String, zip: String) {
        self.address = address
        self.city = city
        self.state = state
        self.zip = zip
    }
    
    init(entity: BillingAddressEntity) {
        self.address = entity.address
        self.city = entity.city
        self.state = entity.state
        self.zip = entity.zip
    }
    
    init(zip: String? = "") {
        self.zip = zip ?? ""
    }
}

//
//  BillingAddressEntity.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//

import Foundation
import RealmSwift
public class BillingAddressEntity: Object, RealmOptionalType {
    @objc dynamic var address: String = ""
    @objc dynamic var city: String = ""
    @objc dynamic var state: String = ""
    @objc dynamic var zip: String = ""
    
    static func create(with billingAddress: BillingAddress) -> BillingAddressEntity {
        let billingAddressEntity = BillingAddressEntity()
        billingAddressEntity.address = billingAddress.address
        billingAddressEntity.city = billingAddress.city
        billingAddressEntity.state = billingAddress.state
        billingAddressEntity.zip = billingAddress.zip
        return billingAddressEntity
    }
}


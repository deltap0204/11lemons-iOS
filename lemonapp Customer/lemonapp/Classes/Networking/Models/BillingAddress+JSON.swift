//
//  BillingAddress+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON


extension BillingAddress: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> BillingAddress {
        let address = j["BillingAddress"].stringValue
        let city = j["BillingCity"].stringValue
        let state = j["BillingState"].stringValue
        let zip = j["BillingZip"].stringValue
        let billingAddress = BillingAddress(address: address, city: city, state: state, zip: zip)
        return billingAddress
    }
}


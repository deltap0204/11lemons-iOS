//
//  OrderAmount+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON


extension OrderAmount: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> OrderAmount {
        let orderAmount = OrderAmount()
        orderAmount.amount = j["AmountWithTax"].doubleValue
        orderAmount.numberOfItems = j["OrderItems"].intValue
        orderAmount.amountWithoutTax = j["Amount"].doubleValue
        orderAmount.tax = j["Tax"].doubleValue
        orderAmount.state = j["TaxState"].stringValue ?? ""
        return orderAmount
    }
}

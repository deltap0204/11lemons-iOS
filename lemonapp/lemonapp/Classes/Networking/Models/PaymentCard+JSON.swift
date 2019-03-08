//
//  PaymentCard+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



extension PaymentCard: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> PaymentCard {
        
        let id: Int = try j["PaymentID"].value()
        
        return PaymentCard(
            id: id,
            number: try j["CardNumber"].value(),
            type: try j["CardType"].value(),
            expiration: try j["CardExpiration"].value(),
            secCode: try j["CardSecCode"].value(),
            deleted: try j["Deleted"].value(),
            userId: try j["UserID"].value(),
            token: try? j["CardToken"].value(),
            billingAddress: try? BillingAddress.decode(j))
    }
}

extension PaymentCard: Encodable {
    
    func encode() -> [String : AnyObject] {
        
        var number: String = ""
        if self.number.count > self.type.numberPattern.last {
            self.type.numberPattern.dropLast().forEach {
                number += $0 * "x" + " "
            }
        }
        if self.type == .AMERICAN_EXPRESS {
            number += "x"
        }
        number += self.number.substring(from: self.number.index(self.number.endIndex, offsetBy: -(self.type.numberPattern.last ?? 0)))
        
        return [
            "PaymentID"      : self.id as AnyObject ?? "" as AnyObject,
            "CardType"       : self.type.rawValue as AnyObject,
            "CardNumber"     : number as AnyObject,
            "CardExpiration" : self.expiration as AnyObject,
            "CardSecCode"    : "000" as AnyObject,
            "UserID"         : "\(self.userId)" as AnyObject,
            "CardToken"      : self.token as AnyObject ?? "" as AnyObject,
            "BillingZip"     : self.billingAddress?.zip as AnyObject ?? "" as AnyObject,
        ]
    }
    
}

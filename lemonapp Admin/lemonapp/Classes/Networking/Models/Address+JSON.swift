//
//  Address+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON


extension Address: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> Address {
        
        let auxAddress = Address(
            id: try? j["AddressID"].value(),
            street: try j["Street"].value(),
            aptSuite: (try? j["AptSuite"].value()) ?? "",
            city: try j["City"].value(),
            state: try j["State"].value(),
            zip: try j["Zip"].value(),
            nickname: try j["Nickname"].value(),
            deleted: try j["Deleted"].value(),
            userId: try j["UserID"].value(),
            notes: (try? j["Notes"].value() ?? "")
        )
        
        return auxAddress
    }
}

extension Address: Encodable {
    
    func encode() -> [String : AnyObject] {
        return [
            "AddressID" : self.id as AnyObject ,
            "Street"    : self.street as AnyObject,
            "AptSuite"  : self.aptSuite as AnyObject,
            "City"      : self.city as AnyObject,
            "State"     : self.state as AnyObject,
            "Zip"       : self.zip as AnyObject,
            "Nickname"  : self.nickname as AnyObject,
            "UserID"    : self.userId as AnyObject,
            "Notes"     : self.notes as AnyObject
        ]
    }
    
}

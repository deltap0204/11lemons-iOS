//
//  FaqItem+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON


extension FaqItem: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> FaqItem {
        return FaqItem(question: j["Question"].stringValue, answer: j["Answer"].stringValue)
    }
}

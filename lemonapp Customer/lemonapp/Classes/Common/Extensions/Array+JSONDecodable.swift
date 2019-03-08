//
//  Array+JSONDecodable.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import SwiftyJSON

extension Array where Element: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> Array {
        let array = try j.array()
        return array.flatMap { try? Element.decode($0) }
    }
    
}

//
//  JSONDecodable.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import SwiftyJSON

protocol JSONDecodable {
    
    static func decode(_ j: JSON) throws -> Self
    
}

protocol Encodable {
    
    func encode() -> [String: AnyObject]
    
}

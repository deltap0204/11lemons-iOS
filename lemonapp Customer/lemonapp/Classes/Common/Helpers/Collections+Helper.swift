//
//  Collections+Helper.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation

extension Collection {
    
    func find(_ predicate: (Self.Iterator.Element) throws -> Bool) rethrows -> Self.Iterator.Element? {
        guard let index = try index(where: predicate) else { return nil }
        return self[index]
    }    
}

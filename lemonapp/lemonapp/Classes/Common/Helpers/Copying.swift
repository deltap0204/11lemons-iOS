//
//  Copying.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

protocol Copying {
    init (original: Self)
}


extension Copying {
    func copy() -> Self {
        return Self.init(original: self)
    }
}

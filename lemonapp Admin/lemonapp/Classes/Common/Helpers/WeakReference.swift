//
//  WeakReference.swift
//  lemonapp
//
//  Created by mac-190-mini on 12/24/15.
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation

struct WeakReference<T: AnyObject> {
    
    weak var value: T?
    
    init(_ value: T) {
        self.value = value
    }
    
}

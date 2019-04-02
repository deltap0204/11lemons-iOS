//
//  Dictionary+Breadcrum.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 19/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//

import Foundation
extension Dictionary where Key == String, Value == Any {
    func prunedForBreadcrum() -> Dictionary<Key, Value> {
        var result : Dictionary<Key, Value> = [:]
        let allowedKeys = ["id", "identifier", "tabName",
                           "workout_id","filters","clubs", "name",
                           "email","class_name","user_id","advanced","tagfilters", "instructors", "clubs","classes",
                           "Instructors", "Clubs", "Classes","permissionType" ]
        
        func toDictionary(_ value : Any) -> Dictionary<String, Any>? {
            return value as? Dictionary<String, Any>
        }
        allowedKeys.forEach { key in
            if let value = self[key] {
                if let dictionary = toDictionary(value) {
                    result[key] = dictionary.prunedForBreadcrum()
                } else if let arrayOfDictionaries = value as? [ Dictionary<String, Any> ] {
                    result[key] = arrayOfDictionaries.compactMap { toDictionary($0)?.prunedForBreadcrum() }
                } else {
                    result[key] = value
                }
            }
        }
        return result
    }
}

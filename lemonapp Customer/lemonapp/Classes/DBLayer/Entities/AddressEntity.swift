//
//  AddressEntity.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//


import Foundation
import RealmSwift
public class AddressEntity: Object, RealmOptionalType {
    let id = RealmOptional<Int>()
    @objc dynamic var street = ""
    @objc dynamic var aptSuite = ""
    @objc dynamic var city = ""
    @objc dynamic var state = ""
    @objc dynamic var zip = ""
    @objc dynamic var nickname = ""
    @objc dynamic var deleted = false
    @objc dynamic var userId = 0
    var notes: String? = nil
    
    static func create(with address: Address) -> AddressEntity {
        let addressEntity = AddressEntity()
        
        addressEntity.id.value = address.id
        addressEntity.street = address.street
        addressEntity.aptSuite = address.aptSuite
        addressEntity.city = address.city
        addressEntity.state = address.state
        addressEntity.zip = address.zip
        addressEntity.nickname = address.nickname
        addressEntity.deleted = address.deleted
        addressEntity.userId = address.userId
        addressEntity.notes = address.notes
        
        return addressEntity
    }
}

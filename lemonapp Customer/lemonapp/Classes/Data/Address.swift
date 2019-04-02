//
//  Address.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation


final class Address: Copying, Equatable {
    
    var id: Int?
    var street: String
    var aptSuite: String
    var city: String
    var state: String
    var zip: String 
    var nickname: String
    var deleted: Bool
    var userId: Int
    var notes: String?
    
    init (id: Int? = nil,
        street: String = "",
        aptSuite: String = "",
        city: String = "",
        state: String = "",
        zip: String = "",
        nickname: String = "",
        deleted: Bool = false,
        userId: Int,
        notes: String? = nil) {
            self.id = id
            self.street = street
            self.aptSuite = aptSuite
            self.city = city
            self.state = state
            self.zip = zip
            self.nickname = nickname
            self.deleted = deleted
            self.userId = userId
            self.notes = notes
    }
    
    convenience init (original: Address) {
        self.init (id: original.id,
            street: original.street,
            aptSuite: original.aptSuite,
            city: original.city,
            state: original.state,
            zip: original.zip,
            nickname: original.nickname,
            deleted: original.deleted,
            userId: original.userId,
            notes: original.notes)
    }
    
    convenience init(entity: AddressEntity) {
        self.init(id: entity.id.value,
                  street: entity.street,
                  aptSuite: entity.aptSuite,
                  city: entity.city,
                  state: entity.state,
                  zip: entity.zip,
                  nickname: entity.nickname,
                  deleted: entity.deleted,
                  userId: entity.userId,
                  notes: entity.notes)
    }
    
    func sync(_ address: Address) {
        self.id = address.id
        self.street = address.street
        self.aptSuite = address.aptSuite
        self.city = address.city
        self.state = address.state
        self.zip = address.zip
        self.nickname = address.nickname
        self.deleted = address.deleted
        self.userId = address.userId
        self.notes = address.notes
    }
    
}
extension Address: OptionItemProtocol {
    
    var label: String {
        return self.nickname
    }
    
    var image: UIImage? {
        return nil
    }
}

func == (left: Address, right: Address) -> Bool {
    return left.id == right.id
}


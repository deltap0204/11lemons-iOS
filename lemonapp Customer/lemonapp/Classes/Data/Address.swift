//
//  Address.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation
import CoreData

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
    
    fileprivate var _dataModel: AddressModel
    
    init (id: Int? = nil,
        street: String = "",
        aptSuite: String = "",
        city: String = "",
        state: String = "",
        zip: String = "",
        nickname: String = "",
        deleted: Bool = false,
        userId: Int,
        notes: String? = nil,
        dataModel: AddressModel? = nil) {
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
            self._dataModel = dataModel ?? AddressModel(id: id, street: street, aptSuite: aptSuite, city: city, state: state, zip: zip, label: nickname, removed: deleted, userId: userId, notes: notes)
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
        syncDataModel()
    }
    
}

extension Address: DataModelWrapper {
    
    var dataModel: NSManagedObject {
        return _dataModel
    }
    
    func syncDataModel() {
        if let id = self.id {
            _dataModel.id = NSNumber(value: id as Int)
            _dataModel.label = self.nickname
            _dataModel.street = self.street
            _dataModel.state = self.state
            _dataModel.city = self.city
            _dataModel.aptSuite = self.aptSuite
            _dataModel.removed = self.deleted
            _dataModel.zip = self.zip
            _dataModel.userId = NSNumber(value: self.userId as Int)
            _dataModel.notes = self.notes
            saveDataModelChanges()
        }
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

extension Address {
    convenience init(addressModel: AddressModel) {
        
        self.init (id: addressModel.id?.intValue,
            street: addressModel.street,
            aptSuite: addressModel.aptSuite,
            city: addressModel.city,
            state: addressModel.state,
            zip: addressModel.zip,
            nickname: addressModel.label,
            deleted: addressModel.removed,
            userId: addressModel.userId.intValue,
            notes: addressModel.notes,
            dataModel: addressModel)
    }
}


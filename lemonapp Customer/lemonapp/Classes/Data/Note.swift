//
//  Note.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation

public enum NoteType {
    case orderNote, customerNote, buildingNote
    
    static let allValues = [orderNote, customerNote, buildingNote]
    
    var alertTitle: String {
        switch self {
        case .orderNote:
            return "Add Order Note"
        case .customerNote:
            return "Add Customer Note"
        case .buildingNote:
            return "Add Building Note"
        }
    }
    
    var typeString: String {
        switch self {
        case .orderNote:
            return "Order"
        case .customerNote:
            return "Customer"
        case .buildingNote:
            return "Building"
        }
    }
}

open class Note {
    var type: NoteType
    var ownerId: String
    var text: String
    
    init(type: NoteType, order: Order, text: String) {
        self.type = type
        self.text = text
        switch type {
        case .buildingNote:
            self.ownerId = String.init(format: "%d", order.delivery.dropoffAddressId ?? 0)
            break
        case .customerNote:
            self.ownerId = String.init(format: "%d", order.createdBy?.id ?? 0)
            break
        case .orderNote:
            self.ownerId = String.init(format: "%d", order.id)
            break
        }
    }
}

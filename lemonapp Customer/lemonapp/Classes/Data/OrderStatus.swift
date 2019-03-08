//
//  OrderStatus.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation


enum OrderStatus : Int {

    case awaitingPickup = 1
    case pickedUp = 2
    case atFacility = 3
    case outForDelivery = 4
    case delivered = 5
    case archived = 6
    case hold = 7
    case canceled = 8
    case scheduled = 9
    
    static let allValues = [awaitingPickup, pickedUp, atFacility, outForDelivery, delivered, archived, hold, canceled, scheduled]
    
    var title: String {
        switch self {
        case .awaitingPickup, .pickedUp, .atFacility, .outForDelivery, .scheduled:
            return NSLocalizedString("Arriving", comment: "")
        case .delivered:
            return NSLocalizedString("Delivered", comment: "")
        case .archived:
            return NSLocalizedString("Archived", comment: "")
        case .hold:
            return NSLocalizedString("Order Hold: Follow up required", comment: "")
        case .canceled:
            return NSLocalizedString("Canceled", comment: "")
        }
    }
    
    var subtitle: String {
        switch self {
        case .awaitingPickup:
            return NSLocalizedString("Awaiting Pickup", comment: "")
        case .pickedUp:
            return NSLocalizedString("Picked Up", comment: "")
        case .atFacility:
            return NSLocalizedString("At Facility", comment: "")
        case .outForDelivery:
            return NSLocalizedString("Out for Delivery", comment: "")
        case .delivered:
            return NSLocalizedString("Delivered", comment: "")
        case .archived:
            return NSLocalizedString("Archived", comment: "")
        case .hold:
            return NSLocalizedString("On hold", comment: "")
        case .canceled:
            return NSLocalizedString("Canceled", comment: "")
        case .scheduled:
            return NSLocalizedString("Scheduled Pickup", comment: "")
        }
    }
    
    func comments(_ date: Date?) -> String {
        
        var dateString = ""
        if let date = date {
            if date.isToday {
                dateString = "today by \(date.stringWithFormat("h:mm a"))"
            } else {
                dateString = date.stringWithFormat("EEE h:mm a")
            }
        }
        switch self {
        case .awaitingPickup:
            return "Pickup " + dateString
        case .atFacility,
            .pickedUp,
            .outForDelivery:
            return "Delivery " + dateString
        case .delivered,
            .canceled:
            return "Order complete"
        default:
            return ""
        }
    }
    
    var shouldShowArrival: Bool {
        switch self {
        case .hold, .canceled, .archived:
            return false
        default:
            return true
        }
    }
    
    var isExceptional: Bool {
        return self == .hold
    }
    
    var image: UIImage? {
        var imageName = ""
        switch self {
        case .awaitingPickup:
            imageName = "ic_awaiting_pickup"
        case .pickedUp:
            imageName = "ic_picked_up"
        case .atFacility:
            imageName = "ic_at_facility"
        case .outForDelivery:
            imageName = "ic_out_for_delivery"
        case .delivered:
            imageName = "ic_delivered"
        case .archived:
            imageName = "ic_archived"
        case .hold:
            imageName = "ic_on_hold"
        case .canceled:
            imageName = "ic_canceled"
        case .scheduled:
            imageName = "ic_scheduled_pickup"
        }
        return UIImage(named: imageName)
    }
    
    var otherAvailableStatuses: [OrderStatus] {
        var statuses: [OrderStatus] = []
        
        if self != OrderStatus.awaitingPickup { statuses.append(.awaitingPickup) }
        if self != OrderStatus.pickedUp { statuses.append(.pickedUp) }
        if self != OrderStatus.atFacility { statuses.append(.atFacility) }
        if self != OrderStatus.outForDelivery { statuses.append(.outForDelivery) }
        if self != OrderStatus.delivered { statuses.append(.delivered) }
        if self != OrderStatus.archived { statuses.append(.archived) }
        if self != OrderStatus.hold { statuses.append(.hold) }
        if self != OrderStatus.canceled { statuses.append(.canceled) }
        
        return statuses
    }
    
    var nextStatus: OrderStatus? {
        switch self {
        case .awaitingPickup:
            return OrderStatus.pickedUp
        case .pickedUp:
            return OrderStatus.atFacility
        case .atFacility:
            return OrderStatus.outForDelivery
        case .outForDelivery:
            return OrderStatus.delivered
        default:
            return nil
        }
    }
}

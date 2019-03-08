//
//  OrderModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

open class OrderModel: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var userId: NSNumber?
    @NSManaged var placed: Date?
    @NSManaged var repeatState: Bool
    @NSManaged var notes: String
    @NSManaged var feedbackText: String
    @NSManaged var feedbackRating: NSNumber
    @NSManaged var deliveryUpchargeAmount: NSNumber?
    @NSManaged var deliveryDate: Date?
    @NSManaged var deliveryEstimatedArrivalDate: Date?
    @NSManaged var deliveryEstimatedPickupDate: Date?
    @NSManaged var status: NSNumber
    @NSManaged var paymentStatus: NSNumber
    @NSManaged var amount: NSNumber
    @NSManaged var numberOfItems: NSNumber
    @NSManaged var amountWithoutTax: NSNumber
    @NSManaged var amountTax: NSNumber
    @NSManaged var amountState: String
    @NSManaged var paymentId: NSNumber?
    @NSManaged var detergent: String
    @NSManaged var shirt: String
    @NSManaged var serviceType: String
    @NSManaged var dryer: String
    @NSManaged var softener: String
    @NSManaged var tips: NSNumber
    @NSManaged var details: Set<OrderDetailsModel>
    @NSManaged var orderImages: Set<OrderImagesModel>
    @NSManaged var lastModified: Date?
    @NSManaged var viewed: Bool
    @NSManaged var lastModifiedUser: UserModel?
    @NSManaged var createdBy: UserModel?
    @NSManaged var pickUpAddress: AddressModel?
    @NSManaged var dropOffAddress: AddressModel?
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init() {
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: LemonCoreDataManager.context)!
        self.init(entity: entity, insertInto: nil)
    }
}

extension OrderModel: ModelNameProvider {
    class var modelName: String { return "Order" }
}

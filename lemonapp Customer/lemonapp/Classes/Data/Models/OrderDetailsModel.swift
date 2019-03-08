//
//  OrderDetailsModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class OrderDetailsModel: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var orderID: NSNumber?
    @NSManaged var quantity: NSNumber?
    @NSManaged var price: NSNumber?
    @NSManaged var pricePer: NSNumber?
    @NSManaged var priceWithoutTaxes: NSNumber?
    @NSManaged var tax: NSNumber?
    @NSManaged var total: NSNumber?
    @NSManaged var subtotal: NSNumber?
    @NSManaged var weight: NSNumber?
    @NSManaged var service: ServiceModel?
    @NSManaged var garment: OrderGarmentModel?
    @NSManaged var jsonOrder: OrderDetailsReceiptModel?
    
    @NSManaged var product: ProductModel?
    
    @NSManaged var order: OrderModel?
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init () {
        let entity = NSEntityDescription.entity(forEntityName: OrderDetailsModel.modelName, in: LemonCoreDataManager.context)!
        self.init(entity: entity, insertInto: nil)
    }
}

extension OrderDetailsModel: ModelNameProvider {
    class var modelName: String { return "OrderDetails" }
}

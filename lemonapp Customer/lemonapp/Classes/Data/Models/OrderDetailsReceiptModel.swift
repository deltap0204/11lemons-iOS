//
//  OrderDetailsReceiptModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 4/6/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class OrderDetailsReceiptModel: NSManagedObject {
    
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
    
    @NSManaged var product: ProductModel?
    
    @NSManaged var order: OrderModel?
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init () {
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: LemonCoreDataManager.context)!
        self.init(entity: entity, insertInto: nil)
    }
}

extension OrderDetailsReceiptModel: ModelNameProvider {
    class var modelName: String { return "OrderDetailsReceipt" }
}


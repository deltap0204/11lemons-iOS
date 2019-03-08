//
//  OrderDetail.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


final class OrderDetail: OrderDetailGeneral {
    var jsonOrder: OrderDetailsReceipt?

    override init(id: Int) {
        super.init(id: id)
    }
    
    init(entity: OrderDetailEntity) {
        super.init(id: entity.id,
                   orderId: entity.orderId,
                   quantity: entity.quantity.value,
                   pricePer: entity.pricePer.value,
                   priceWithoutTaxes: entity.priceWithoutTaxes.value,
                   tax: entity.tax.value,
                   total: entity.total.value,
                   subtotal: entity.subtotal.value,
                   weight: entity.weight.value,
                   service: entity.service.map {Service(entity: $0)},
                   garment: entity.garment.map { OrderGarment(entity: $0) },
                   product: entity.product.map { Product(entity: $0) })

        if let json = entity.jsonOrder {
            self.jsonOrder = OrderDetailsReceipt(entity: json)
        } else {
            self.jsonOrder = nil
        }
    }
}

//extension OrderDetail: DataModelWrapper {
//
//    var dataModel: NSManagedObject {
//        return _dataModel
//    }
//
//    func syncDataModel() {
//        _dataModel.id = NSNumber(value: id as Int)
//        _dataModel.orderID = NSNumber(value: orderId as Int)
//        _dataModel.quantity = quantity == nil ? nil : NSNumber(value: quantity! as Int)
//        _dataModel.pricePer = pricePer == nil ? nil : NSNumber(value: pricePer! as Double)
//        _dataModel.priceWithoutTaxes = priceWithoutTaxes == nil ? nil : NSNumber(value: priceWithoutTaxes! as Double)
//        _dataModel.tax = tax == nil ? nil : NSNumber(value: tax! as Double)
//        _dataModel.total = total == nil ? nil : NSNumber(value: total! as Double)
//        _dataModel.subtotal = subtotal == nil ? nil : NSNumber(value: subtotal! as Double)
//        _dataModel.weight = weight == nil ? nil : NSNumber(value: weight! as Double)
//        _dataModel.product = self.product?.dataModel as? ProductModel
//        _dataModel.garment = garment?.dataModel as? OrderGarmentModel
//        _dataModel.service = service?.dataModel as? ServiceModel
//        _dataModel.jsonOrder = jsonOrder?.dataModel as? OrderDetailsReceiptModel
//    }
//}

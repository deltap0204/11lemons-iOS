//
//  OrderDetail.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class OrderDetail: OrderDetailGeneral {
    var jsonOrder: OrderDetailsReceipt?
    
    fileprivate var _dataModel: OrderDetailsModel = OrderDetailsModel()
    
    convenience init(orderDetailModel: OrderDetailsModel) {
        self.init(id: orderDetailModel.id.intValue)
        if let orderID = orderDetailModel.orderID {
            orderId = orderID.intValue
        }
        quantity = orderDetailModel.quantity?.intValue
        pricePer = orderDetailModel.pricePer?.doubleValue
        priceWithoutTaxes = orderDetailModel.priceWithoutTaxes?.doubleValue
        tax = orderDetailModel.tax?.doubleValue
        total = orderDetailModel.total?.doubleValue
        subtotal = orderDetailModel.subtotal?.doubleValue
        weight = orderDetailModel.weight?.doubleValue
        
        if let garment = orderDetailModel.garment {
            self.garment = OrderGarment(orderGarmentModel: garment)
        }
        
        if let service = orderDetailModel.service {
            self.service = Service(serviceModel: service)
        }
        
        if let jsonOrder = orderDetailModel.jsonOrder {
            self.jsonOrder = OrderDetailsReceipt(orderDetailModel: jsonOrder)
        }
        
        _dataModel = orderDetailModel
        if let productModel = _dataModel.product {
            self.product = Product(productModel: productModel)
        }
    }
    
    func sync(_ orderDetail: OrderDetail) {
        quantity = orderDetail.quantity
        pricePer = orderDetail.pricePer
        priceWithoutTaxes = orderDetail.priceWithoutTaxes
        tax = orderDetail.tax
        total = orderDetail.total
        subtotal = orderDetail.subtotal
        weight = orderDetail.weight
        garment = orderDetail.garment
        service = orderDetail.service
        orderId = orderDetail.orderId
        jsonOrder = orderDetail.jsonOrder
        syncDataModel()
    }
}

extension OrderDetail: DataModelWrapper {
    
    var dataModel: NSManagedObject {
        return _dataModel
    }
    
    func syncDataModel() {
        _dataModel.id = NSNumber(value: id as Int)
        _dataModel.orderID = NSNumber(value: orderId as Int)
        _dataModel.quantity = quantity == nil ? nil : NSNumber(value: quantity! as Int)
        _dataModel.pricePer = pricePer == nil ? nil : NSNumber(value: pricePer! as Double)
        _dataModel.priceWithoutTaxes = priceWithoutTaxes == nil ? nil : NSNumber(value: priceWithoutTaxes! as Double)
        _dataModel.tax = tax == nil ? nil : NSNumber(value: tax! as Double)
        _dataModel.total = total == nil ? nil : NSNumber(value: total! as Double)
        _dataModel.subtotal = subtotal == nil ? nil : NSNumber(value: subtotal! as Double)
        _dataModel.weight = weight == nil ? nil : NSNumber(value: weight! as Double)
        _dataModel.product = self.product?.dataModel as? ProductModel
        _dataModel.garment = garment?.dataModel as? OrderGarmentModel
        _dataModel.service = service?.dataModel as? ServiceModel
        _dataModel.jsonOrder = jsonOrder?.dataModel as? OrderDetailsReceiptModel
    }
}

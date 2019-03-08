//
//  OrderDetail+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON


extension OrderDetail: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> OrderDetail {
        let id = j["OrderDetailID"].intValue
        let detail = OrderDetail(id: id)
        detail.orderId = j["OrderID"].intValue
        detail.quantity = j["Quantity"].intValue
        detail.pricePer = j["PricePer"].doubleValue
        detail.priceWithoutTaxes = j["Subtotal"].doubleValue
        detail.tax = j["Tax"].doubleValue
        detail.total = j["Total"].doubleValue
        detail.subtotal = j["Subtotal"].doubleValue
        detail.weight = j["Weight"].doubleValue
        detail.product = try Product.decode(j["Products"])
        detail.service = try Service.decode(j["Service"])
        detail.garment = try OrderGarment.decode(j["Garment"])
        detail.jsonOrder = try OrderDetailsReceipt.decode(j["JSONString"])
        return detail
    }
}

extension OrderDetail: Encodable {
    
    func encode() -> [String : AnyObject] {
        var returnArray: [String : AnyObject] = [:]
        returnArray["OrderDetailID"] = id as AnyObject
        returnArray["OrderId"] = orderId as AnyObject
        returnArray["Quantity"] = (quantity ?? 1) as AnyObject
        returnArray["PricePer"] = pricePer as AnyObject
        returnArray["Subtotal"] = priceWithoutTaxes as AnyObject
        returnArray["Tax"] = tax as AnyObject
        returnArray["Total"] = total as AnyObject
        returnArray["Subtotal"] = subtotal as AnyObject
        returnArray["Weight"] = (weight ?? 0) as AnyObject
        returnArray["Products"] = (product?.encode() as AnyObject) ?? "" as AnyObject
        returnArray["Service"] = service?.encode() as AnyObject ?? "" as AnyObject
        returnArray["Garment"] = garment?.encode() as AnyObject ?? "" as AnyObject
        
        return returnArray
    }
    
}

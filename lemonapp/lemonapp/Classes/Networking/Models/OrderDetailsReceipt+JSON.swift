//
//  OrderDetailsReceipt+JSON.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 4/6/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON

extension OrderDetailsReceipt: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> OrderDetailsReceipt {
        var id = j["OrderDetailID"].intValue
        var detail = OrderDetailsReceipt(id: id)
        let string = j.rawString()
        if let data = string?.data(using: String.Encoding.utf8) {
            let json = try JSON(data: data, options: [JSONSerialization.ReadingOptions.allowFragments])
            id = json["OrderDetailID"].intValue
            detail = OrderDetailsReceipt(id: id)
            detail.orderId = json["OrderID"].intValue
            detail.quantity = json["Quantity"].intValue
            detail.pricePer = json["PricePer"].doubleValue
            detail.priceWithoutTaxes = json["Subtotal"].doubleValue
            detail.tax = json["Tax"].double
            detail.total = json["Total"].double
            detail.subtotal = json["Subtotal"].double
            detail.weight = json["Weight"].double
            detail.product = try Product.decode(json["Products"])
            detail.service = try Service.decode(json["Service"])
            detail.garment = try OrderGarment.decode(json["Garment"])
        }
        
        return detail
    }
}

extension OrderDetailsReceipt: Encodable {
    
    func encode() -> [String : AnyObject] {
        var returnArray: [String : AnyObject] = [:]
        returnArray["OrderDetailID"] = id as AnyObject
        returnArray["OrderId"] = orderId as AnyObject
        returnArray["Quantity"] = quantity as AnyObject
        returnArray["PricePer"] = pricePer as AnyObject
        returnArray["Subtotal"] = priceWithoutTaxes as AnyObject
        returnArray["Tax"] = tax as AnyObject
        returnArray["Total"] = total as AnyObject
        returnArray["Subtotal"] = subtotal as AnyObject
        returnArray["Weight"] = weight as AnyObject
        returnArray["Products"] = (product?.encode() as AnyObject) ?? "" as AnyObject
        returnArray["Service"] = service?.encode() as AnyObject ?? "" as AnyObject
        returnArray["Garment"] = garment?.encode() as AnyObject ?? "" as AnyObject
        
        return returnArray
    }
    
}


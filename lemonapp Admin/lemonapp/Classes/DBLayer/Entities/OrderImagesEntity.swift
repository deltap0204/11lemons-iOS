//
//  OrderImagesEntity.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//


import Foundation
import RealmSwift
public class OrderImagesEntity: Object {
    override public static func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var id = 0
    @objc dynamic var orderID = 0
    @objc dynamic var imageURL = ""
    
    static func create(with orderImages: OrderImages) -> OrderImagesEntity {
        let orderImagesEntity = OrderImagesEntity()
        orderImagesEntity.id = orderImages.id
        orderImagesEntity.orderID = orderImages.orderID
        orderImagesEntity.imageURL = orderImages.imageURL
        return orderImagesEntity
    }
}


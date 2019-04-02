//
//  OrderImages.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


final class OrderImages {
    
    var id: Int
    var orderID: Int = 0
    var imageURL: String = ""

    
    init(id: Int) {
        self.id = id
    }
    
    init(entity: OrderImagesEntity) {
        self.id = entity.id
        self.orderID = entity.orderID
        self.imageURL = entity.imageURL
    }
    
    func sync(_ orderImages: OrderImages) {
        orderID = orderImages.orderID
        imageURL = orderImages.imageURL
    }
}

//
//  OrderPhoto.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit

class OrderPhoto {
    let orderId: Int
    let orderPicId: Int
    let photo: UIImage
    
    init(orderId: Int, orderPicId: Int, photo: UIImage) {
        self.orderId = orderId
        self.orderPicId = orderPicId
        self.photo = photo
    }
}

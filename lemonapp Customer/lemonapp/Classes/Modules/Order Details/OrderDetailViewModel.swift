//
//  OrderDetailViewModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


enum DetailType {
    case info, summary, general, payment
}


class OrderDetailViewModel {

    var title = ""
    var info = ""
    var infoTitle = ""
    var type: DetailType = .general
    var detail: OrderDetail?
    var detailList: [OrderDetail]?
    var showsAccessory: Bool {
        return type != .payment
    }
}

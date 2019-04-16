//
//  PaymentSectionViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 11/14/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond

final class PaymentSectionViewModel {
    
    let paymentId = Observable<Int>(0)
    let cardNumber = Observable<String>("Apple Pay")
    let statusColor = Observable<UIColor>(UIColor.paymentNotProcessedColor)
    let methodImageNamed = Observable<UIImage>(UIImage(named: "ApplePayIconWhiteWithoutBorder")!)
    let imageStatus: UIImage
    var action: ActionB?
    
    init(order: Order) {
        if order.applePayToken == nil || order.applePayToken == "" {
            if let card = order.card {
                self.cardNumber.value = card.number
                self.methodImageNamed.value = card.type.image ?? UIImage(named: "ApplePayIconWhiteWithoutBorder")!
            } else {
                self.methodImageNamed.value = UIImage(named: "ApplePayIconWhiteWithoutBorder")!
                self.cardNumber.value = "Apple Pay"
            }
            
            self.paymentId.value = order.paymentId ?? 0
        }
        self.imageStatus = OrderHelper.getReceiptPaymentStatus(order)
        self.statusColor.value = order.paymentStatus.color
    }
}


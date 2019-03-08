//
//  ApplePayCard.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import PassKit

final class ApplePayCard {
    
    var label: String = "Apple Pay"
    
    static func isApplePayAvailable() -> Bool {
        return PKPaymentAuthorizationViewController.canMakePayments() && PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [PKPaymentNetwork.amex, PKPaymentNetwork.masterCard, PKPaymentNetwork.visa])
    }
}

extension ApplePayCard: PaymentCardProtocol {
    
    var id: Int? { return -1 }
    
    var image: UIImage? {
        return UIImage(assetIdentifier: .ApplePayIconWhite).withRenderingMode(.alwaysOriginal)
    }
    
    var lightImage: UIImage? {
        return UIImage(assetIdentifier: .ApplePayIconWhiteWithoutBorder).withRenderingMode(.alwaysOriginal)
    }
}


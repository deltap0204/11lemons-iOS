//
//  PKPaymentRequest.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import PassKit

extension PKPaymentRequest {
    
    static var lemonPaymentRequest: PKPaymentRequest {
        let paymentRequest = PKPaymentRequest()
        if #available(iOS 9.0, *) {
            paymentRequest.supportedNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex, PKPaymentNetwork.discover, PKPaymentNetwork.privateLabel]
        } else {
            paymentRequest.supportedNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]
        };
        paymentRequest.merchantCapabilities = PKMerchantCapability.capability3DS;
        paymentRequest.currencyCode = "USD";
        paymentRequest.countryCode = "US";
        paymentRequest.merchantIdentifier = Config.MerchantId
        
        if  #available(iOS 9.0, *) {
            paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: "11Lemons Service", amount: NSDecimalNumber(value: 1.0 as Double), type: .pending)]
        } else {
            paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: "11Lemons Service", amount: NSDecimalNumber(value: 1.0 as Double))]
        }
        return paymentRequest
    }
}

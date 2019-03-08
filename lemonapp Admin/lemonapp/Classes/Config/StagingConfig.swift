//
//  StagingConfig.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


final class Config {
    static let MerchantId = "merchant.11lemons.braintree.sandbox"
    
    static let ShouldRegisterForPushes = true
    
    static let StandardPickupETA = 45
    
    static let APIVersion = 2
    
    enum LemonEndpoints:String {
        case APIEndpoint = "http://11lemons-api-test.azurewebsites.net/api/v1"
        case UploadPicturesAPIEndpoint = "http://11lemons-api-test.azurewebsites.net/"
        case PicsEndpoint = "http://11lemonstorage.blob.core.windows.net/"
    }
    
    static let HubName = "push-test"
    static let HubListenAccess = "Endpoint=sb://elevenlemons.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=zfEf7AEMka6az4+/7t0iczO/D+0LWTt+uApH2kRSFkM="
}

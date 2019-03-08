//
//  ProductionConfig.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


final class Config {
    static let MerchantId = "merchant.11lemons.braintree.production"
    
    static let ShouldRegisterForPushes = true
    
    static let StandardPickupETA = 45
    
    static let APIVersion = 2
    
    enum LemonEndpoints:String {
        //case APIEndpoint = "https://lemons-live-api-2.azurewebsites.net/api/v1/"
        case APIEndpoint = "https://11lemonsposapilive.azurewebsites.net/api/v1/"
        //case UploadPicturesAPIEndpoint = "http://lemons-live-api-2.azurewebsites.net/"
        case UploadPicturesAPIEndpoint = "https://11lemonsposapilive.azurewebsites.net/"
        case PicsEndpoint = "https://11lemonstorage.blob.core.windows.net/"
    }
    
    static let HubName = "push-live"
    static let HubListenAccess = "Endpoint=sb://elevenlemons.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=xaTROR/WKB0eZd04EZBIewERCQb4ZqLdO/j6Q64Yous="
}

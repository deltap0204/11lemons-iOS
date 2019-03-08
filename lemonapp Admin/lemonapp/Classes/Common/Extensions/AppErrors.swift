//
//  AppErrors.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

protocol ErrorWithDescriptionType: Error {
    
    var title: String { get }
    var message: String { get }
    
}

enum LemonError: ErrorWithDescriptionType {
    case unknown
    case unknownTypeForParsing
    case archivingFailed
    case applePayNotAvailable
    case invalideCard
    case unableToGetCardToken
    case noInternetConnection
    case unavailableLocation
    case oldApiVersion
    
    var title: String {
        switch self {
        case .unavailableLocation:
            return "Coming Soon..."
        default:
            return ""
        }
    }
    
    var message: String {
        switch self {
        case .unknown:
            return "Sorry, something went wrong"
        case .unableToGetCardToken:
            return "Unable to create Braintree token."
        case .noInternetConnection:
            return "Please, check Internet connection"
        case .invalideCard:
            return "Please, check Card information"
        case .unavailableLocation:
            return "We aren’t currently in your area, but\nwe'll notify as soon as we are."
        case .oldApiVersion:
            return "Please, update the app"
        default: ()
        }
        return ""
    }
}

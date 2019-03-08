//
//  AppStoryboardIdentifiers.swift
//  lemonapp
//
//  Created by mac-190-mini on 12/23/15.
//  Copyright © 2015 11lemons. All rights reserved.
//

import UIKit

enum StoryboardScreenIdentifier: String {
    
    case WelcomePageScreen
    case SignInScreen
    case NewOrderInitialScreen
    case DetailedOrderScreen
    case AddressScreen
    case PaymentCardScreen
    case SettingsScreen
    case AuthScreen
    case CommonContainerScreen
    case OrderServices
    case NewServiceCategory
    case NewService
    case NewAttributeCategory
    case NewAttribute
    case PickAttributeCategory
    case Receipt
    case ServicesSelection
}


enum StoryboardSegueIdentifier: String {
    case OpenAuth
    case SignIn
    case SignUp
    case OrderDetails
    case OpenHome
    case Delivery
    case Addresses
    case Address
    case PaymentCards
    case PaymentCard
    case TermsOfService
    case PrivacyPolicy
    case FAQ
    case ProductDetails
    case SignOut
    case Subproducts
    case NewInfo
    case NewAddress
    case NewPayment
    case ReferralProgram
    case ServiceSelection
    case ServiceDepartmentSelection
    case Receipt
}

extension UIStoryboard {
    
    func instantiateViewControllerWithIdentifier(_ identifier: StoryboardScreenIdentifier) -> UIViewController {
        return self.instantiateViewController(withIdentifier: identifier.rawValue)
    }
}

extension UIViewController {
    
    func performSegueWithIdentifier(_ identifier: StoryboardSegueIdentifier, sender: AnyObject?) {
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
    
    func performSegueWithIdentifier(_ identifier: StoryboardSegueIdentifier) {
        performSegue(withIdentifier: identifier.rawValue, sender: nil)
    }
}

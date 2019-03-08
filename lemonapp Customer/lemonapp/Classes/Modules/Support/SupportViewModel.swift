//
//  SupportViewModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond
import MessageUI


final class SupportViewModel {
    
    let supportItems = MutableObservableArray<SupportCellViewModel>([])
    
    fileprivate let callString = "(914) 249-9534"
    fileprivate let textString = "(914) 249-9534"
    let emailString = "hello@11lemons.com"
    
    var phoneToCall: URL? {
        let phone = phoneFromString(callString)
        if let url = URL(string: "tel:\(phone)"), UIApplication.shared.canOpenURL(url) {
            return url
        }
        return nil
    }
    
    var phoneToText: String {
        return phoneFromString(textString)
    }
    
    init() {
        let call = SupportCellViewModel(supportType: .call, title: "Call Us", value: callString)
        let text = SupportCellViewModel(supportType: .text, title: "Text Us", value: "(914) 249-9534")
        let email = SupportCellViewModel(supportType: .email, title: "Email Us", value: emailString)
        let faq = SupportCellViewModel(supportType: .faq, title: "FAQ")
        let termsOfUse = SupportCellViewModel(supportType: .termsOrUse, title: "Terms & Conditions")
        let policy = SupportCellViewModel(supportType: .privacyPolicy, title: "Privacy Policy")
        var listOfItems = [SupportCellViewModel]()
        if let _ = phoneToCall {
            listOfItems.append(call)
        }
        if MFMessageComposeViewController.canSendText() {
            listOfItems.append(text)
        }
        if MFMailComposeViewController.canSendMail() {
            listOfItems.append(email)
        }
        listOfItems.append(contentsOf: [faq, termsOfUse, policy])
        supportItems.replace(with: listOfItems)
    }
    
    fileprivate func phoneFromString(_ string: String) -> String {
        let phone = (string.components(separatedBy: CharacterSet(charactersIn: "0123456789-+()").inverted) as NSArray).componentsJoined(by: "")
        return phone
    }
}

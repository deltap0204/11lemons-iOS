//
//  String+Validation.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation

extension String {
    
    var isEmail: Bool {
        guard !isEmpty else { return false }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    
    var isMobilePhone: Bool {
        guard !isEmpty else { return false }
        let mobilePhoneRegex = "^\\([0-9]{3}\\) [0-9]{3}-[0-9]{4}$";
        let mobilePhoneTest = NSPredicate(format:"SELF MATCHES %@", mobilePhoneRegex)
        return mobilePhoneTest.evaluate(with: self)
    }
}

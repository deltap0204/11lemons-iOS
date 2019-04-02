//
//  User+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON

extension User: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> User {
        return User(
            id: try j["UserID"].value(),
            firstName: try j["First"].value(),
            lastName: try j["Last"].value(),
            email: try j["Email"].value(),
            mobilePhone: (try? j["Mobile"].value()) ?? "",
            profilePhoto: try? j["ProfilePic"].value(),
            defaultAddressId: try? j["DefaultAddress"].value(),
            defaultPaymentCardId: try? j["DefaultPayment"].value(),
            settings: Settings(notificationString: try? j["Pref_Notification"].value(), cloudClosetEnabled: try? j["Pref_CloudCloset"].value()),
            preferences: try Preferences.decode(j) ,
            walletAmount: j["WalletAmount"].double,
            referralCode: try? j["ReferralCode"].value(),
            isAdmin: false
        )
    }
}


extension User: Encodable {
    
    func encode() -> [String : AnyObject] {
        var params = [
            "UserID" : "\(self.id)",
            "Email" : self.email,
            "Mobile" : self.mobilePhone,
            "Pref_Notification" : self.settings.encodedSetting,
            "Pref_CloudCloset": self.settings.cloudClosetEnabled ? "true" : "false",
            "Pref_Detergent": self.preferences.detergent.rawValue,
            "Pref_Hanger": self.preferences.shirts.rawValue,
            "Pref_Notes": self.preferences.notes,
            "Pref_Fabricsoftener": self.preferences.softener.rawValue,
            "Pref_Dryersheet": self.preferences.dryer.rawValue,
            "Pref_DefaultTipPercent": "\(self.preferences.tips)",
            "Pref_Sched_Freq": "\(self.preferences.scheduledFrequency)",
            "Pref_Sched_Day": self.preferences.scheduledWeekday
        ]
        if let defaultAddressId = self.defaultAddressId {
            params["DefaultAddress"] = "\(defaultAddressId)"
        }
        if let defaultPaymentCardId = self.defaultPaymentCardId {
            params["DefaultPayment"] = "\(defaultPaymentCardId)"
        }
        
        return params as [String : AnyObject]
    }
}

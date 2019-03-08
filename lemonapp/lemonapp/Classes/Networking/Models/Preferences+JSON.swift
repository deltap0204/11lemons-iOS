//
//  Preferences+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import SwiftyJSON


extension Preferences: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> Preferences {
        let detergent = j["Pref_Detergent"].stringValue
        let shirts = j["Pref_Hanger"].stringValue
        let notes = j["Pref_Notes"].stringValue
        let softener = j["Pref_FabricSoftener"].stringValue
        let dryer = j["Pref_DryerSheet"].stringValue
        let tips = j["Pref_DefaultTipPercent"].intValue
        let preferences = Preferences(detergentString: detergent, shirtsString: shirts, dryerString: dryer, softenerString: softener, tips: tips, notes: notes)
        preferences.scheduledWeekday = j["Pref_Sched_Day"].stringValue
        preferences.scheduledFrequency = j["Pref_Sched_Freq"].intValue
        return preferences
    }
}

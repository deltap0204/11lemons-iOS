//
//  PreferencesEntity.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//

import Foundation
import RealmSwift
public class PreferencesEntity: Object {
    @objc dynamic var privateDetergent = Detergent.Original.rawValue
    var detergent: Detergent {
        get { return Detergent(rawValue: privateDetergent)! }
        set { privateDetergent = newValue.rawValue }
    }
    
    @objc dynamic var privateShirts = Shirt.Hanger.rawValue
    var shirts: Shirt {
        get { return Shirt(rawValue: privateShirts)! }
        set { privateShirts = newValue.rawValue }
    }
    
    @objc dynamic var privateDryer = Dryer.Bounce.rawValue
    var dryer: Dryer {
        get { return Dryer(rawValue: privateDryer)! }
        set { privateDryer = newValue.rawValue }
    }
    
    @objc dynamic var privateSoftener = Softener.Downy.rawValue
    var softener: Softener {
        get { return Softener(rawValue: privateSoftener)! }
        set { privateSoftener = newValue.rawValue }
    }
    
    @objc dynamic var tips = 0
    @objc dynamic var notes = ""
    @objc dynamic var scheduledWeekday = ""
    @objc dynamic var scheduledFrequency = 0
    
    
    static func create(with preferences: Preferences) -> PreferencesEntity {
        let preferencesEntity = PreferencesEntity()
        
        preferencesEntity.detergent = preferences.detergent
        preferencesEntity.shirts = preferences.shirts
        preferencesEntity.dryer = preferences.dryer
        preferencesEntity.softener = preferences.softener
        preferencesEntity.tips = preferences.tips
        preferencesEntity.notes = preferences.notes
        preferencesEntity.scheduledWeekday = preferences.scheduledWeekday
        preferencesEntity.scheduledFrequency = preferences.scheduledFrequency
        
        return preferencesEntity
    }
}


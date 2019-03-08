//
//  Preferences.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation



final class Preferences: Copying, Codable {
    
    var detergent: Detergent = .Original
    var shirts: Shirt = .Hanger
    var dryer: Dryer = .Bounce
    var softener: Softener = .Downy
    var tips = 0
    var notes = ""
    var scheduledWeekday = ""
    var scheduledFrequency = 0
    
    fileprivate let DetergentKey = "Detergent"
    fileprivate let ShirtsKey = "Shirts"
    fileprivate let TipsKey = "Tips"
    fileprivate let DryerKey = "Dryer"
    fileprivate let SoftenerKey = "Softener"
    fileprivate let NotesKey = "Notes"
    fileprivate let WeekdayKey = "Weekday"
    fileprivate let FrequencyKey = "Frequency"
    
    init(detergentString: String? = nil, shirtsString: String? = nil, dryerString: String? = nil, softenerString: String? = nil, tips: Int? = nil, notes: String? = nil, weekday: String? = nil, frequency: Int = 0) {
        let defaults = UserDefaults.standard
        if let detergentString = detergentString,
            let detergent = Detergent(rawValue: detergentString) {
                self.detergent = detergent
                defaults.set(detergent.rawValue, forKey: DetergentKey)
                defaults.synchronize()
        } else if let detergentString = defaults.object(forKey: DetergentKey) as? String,
            let detergent = Detergent(rawValue: detergentString) {
            self.detergent = detergent
        } else {
            defaults.set(detergent.rawValue, forKey: DetergentKey)
            defaults.synchronize()
        }
        
        if let shirtsString = shirtsString,
            let shirts = Shirt(rawValue: shirtsString) {
                self.shirts = shirts
                defaults.set(shirts.rawValue, forKey: ShirtsKey)
                defaults.synchronize()
        } else if let shirtsString = defaults.object(forKey: ShirtsKey) as? String,
            let shirts = Shirt(rawValue: shirtsString) {
            self.shirts = shirts
        } else {
            defaults.set(shirts.rawValue, forKey: ShirtsKey)
            defaults.synchronize()
        }
        
        if let dryerString = dryerString,
            let dryer = Dryer(rawValue: dryerString) {
                self.dryer = dryer
                defaults.set(dryer.rawValue, forKey: DryerKey)
                defaults.synchronize()
        } else if let dryerString = defaults.object(forKey: DryerKey) as? String,
            let dryer = Dryer(rawValue: dryerString) {
                self.dryer = dryer
        } else {
            defaults.set(dryer.rawValue, forKey: DryerKey)
            defaults.synchronize()
        }
        
        if let softenerString = softenerString,
            let softener = Softener(rawValue: softenerString) {
            self.softener = softener
            defaults.set(softener.rawValue, forKey: SoftenerKey)
            defaults.synchronize()
        } else if let softenerString = defaults.object(forKey: SoftenerKey) as? String,
            let softener = Softener(rawValue: softenerString) {
            self.softener = softener
        } else {
            defaults.set(softener.rawValue, forKey: SoftenerKey)
            defaults.synchronize()
        }
        
        if let tips = tips {
            self.tips = tips
            defaults.set(tips, forKey: TipsKey)
            defaults.synchronize()
        }
        if let tips = defaults.object(forKey: TipsKey) as? Int {
            self.tips = tips
        } else {
            defaults.set(tips, forKey: TipsKey)
            defaults.synchronize()
        }
        
        if let notes = notes {
            self.notes = notes
            defaults.set(notes, forKey: NotesKey)
            defaults.synchronize()
        }
        if let notes = defaults.object(forKey: NotesKey) as? String {
            self.notes = notes
        } else {
            defaults.set(notes, forKey: NotesKey)
            defaults.synchronize()
        }
        
        if let weekday = defaults.object(forKey: WeekdayKey) as? String {
            self.scheduledWeekday = weekday;
        } else {
            defaults.set(weekday, forKey: WeekdayKey)
            defaults.synchronize();
        }
        
        if let savedFrequency = defaults.object(forKey: FrequencyKey) as? String, savedFrequency.count > 0 {
            self.scheduledFrequency = Int(savedFrequency)!
        } else {
            defaults.set("\(frequency)", forKey: FrequencyKey)
            defaults.synchronize();
        }
    }
    
    init(original: Preferences) {
        self.detergent = original.detergent
        self.shirts = original.shirts
        self.notes = original.notes
        self.tips = original.tips
        self.dryer = original.dryer
        self.softener = original.softener
        self.scheduledWeekday = original.scheduledWeekday
        self.scheduledFrequency = original.scheduledFrequency
    }
    
    func sync(_ preferences: Preferences) {
        self.detergent = preferences.detergent
        self.shirts = preferences.shirts
        self.notes = preferences.notes
        self.tips = preferences.tips
        self.dryer = preferences.dryer
        self.softener = preferences.softener
        self.scheduledWeekday = preferences.scheduledWeekday
        self.scheduledFrequency = preferences.scheduledFrequency
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(detergent.rawValue, forKey: DetergentKey)
        defaults.set(shirts.rawValue, forKey: ShirtsKey)
        defaults.set(notes, forKey: NotesKey)
        defaults.set(dryer.rawValue, forKey: DryerKey)
        defaults.set(softener.rawValue, forKey: SoftenerKey)
        defaults.set(tips, forKey: TipsKey)
        defaults.set("\(scheduledFrequency)", forKey: FrequencyKey)
        defaults.set(scheduledWeekday, forKey: WeekdayKey)
        defaults.synchronize()
    }
}

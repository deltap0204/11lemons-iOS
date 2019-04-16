//
//  SettingsEntity.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//

import Foundation
import RealmSwift
public class SettingsEntity: Object {
    @objc dynamic var cloudClosetEnabled = false
    @objc dynamic var pushEnabled = false
    @objc dynamic var mailEnabled = false
    @objc dynamic var messageEnabled = false
    
    static func create(with settings: Settings) -> SettingsEntity {
        let settingsEntity = SettingsEntity()
        
        settingsEntity.cloudClosetEnabled = settings.cloudClosetEnabled
        settingsEntity.pushEnabled = settings.pushEnabled
        settingsEntity.mailEnabled = settings.mailEnabled
        settingsEntity.messageEnabled = settings.messageEnabled
        
        return settingsEntity
    }
}


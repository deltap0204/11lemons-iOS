//
//  Settings.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit

final class Settings: Copying, Codable {
    
    fileprivate let NotificationKey = "Notification"
    fileprivate let CloudClosetEnabledKey = "CloudCloset"
    
    var cloudClosetEnabled = false
    
    var pushEnabled: Bool = false
    var mailEnabled: Bool = false
    var messageEnabled: Bool = false
    
    //let settingsDidChange: EventProducer<Void> = EventProducer(replayLength: 1)
    //let settingsDidChange: ReplayOneSubject<Void, NSError>
    //let settingsDidChange: SafeSignal<Void> = SafeSignal.just(())
    //let settingsDidChange = SafeReplaySubject<Void>()
    let settingsDidChange = SafeReplayOneSubject<Void>()
    
    var encodedSetting: String {
        var list = [String]()
        if pushEnabled {
            list.append(NotificationsSettings.InApp.rawValue)
        }
        if mailEnabled {
            list.append(NotificationsSettings.Email.rawValue)
        }
        if messageEnabled {
            list.append(NotificationsSettings.Text.rawValue)
        }
        let settings = (list as NSArray).componentsJoined(by: ",")
        return settings
    }
    
    enum CodingKeys: String, CodingKey {
        case pushEnabled, cloudClosetEnabled, mailEnabled, messageEnabled
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pushEnabled = try container.decode(Bool.self, forKey: .pushEnabled)
        self.cloudClosetEnabled = try container.decode(Bool.self, forKey: .cloudClosetEnabled)
        self.mailEnabled = try container.decode(Bool.self, forKey: .mailEnabled)
        self.messageEnabled = try container.decode(Bool.self, forKey: .messageEnabled)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pushEnabled, forKey: .pushEnabled)
        try container.encode(cloudClosetEnabled, forKey: .cloudClosetEnabled)
        try container.encode(mailEnabled, forKey: .mailEnabled)
        try container.encode(messageEnabled, forKey: .messageEnabled)
    }
    
    
    init(notificationString: String? = nil, cloudClosetEnabled: Bool? = nil) {
        let defaults = UserDefaults.standard
        var components = [String]()
        if let notificationString = notificationString {
            components = (notificationString as NSString).components(separatedBy: ",")
        } else if let notificationString = defaults.object(forKey: NotificationKey) as? String {
            components = (notificationString as NSString).components(separatedBy: ",")
        }
        for setting in components {
            if let validSetting = NotificationsSettings(rawValue: setting) {
                switch validSetting {
                case .InApp:
                    pushEnabled = true
                case .Email:
                    mailEnabled = true
                case .Text:
                    messageEnabled = true
                }
            }
        }
        if let cloudClosetEnabled = cloudClosetEnabled {
            self.cloudClosetEnabled = cloudClosetEnabled
        } else if defaults.object(forKey: CloudClosetEnabledKey) != nil {
            self.cloudClosetEnabled = defaults.bool(forKey: CloudClosetEnabledKey)
        } else {
            self.cloudClosetEnabled = false
        }
        settingsDidChange.next()
    }
    
    convenience init(original: Settings) {
        self.init(notificationString: original.encodedSetting)
        self.cloudClosetEnabled = original.cloudClosetEnabled
    }
    
    init(entity: SettingsEntity) {
        self.cloudClosetEnabled = entity.cloudClosetEnabled
        
        self.pushEnabled = entity.pushEnabled
        self.mailEnabled = entity.mailEnabled
        self.messageEnabled = entity.messageEnabled
    }
    
    func sync(_ settings: Settings) {
        pushEnabled = settings.pushEnabled
        mailEnabled = settings.mailEnabled
        messageEnabled = settings.messageEnabled
        cloudClosetEnabled = settings.cloudClosetEnabled
        settingsDidChange.next()
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(encodedSetting, forKey: NotificationKey)
        defaults.set(cloudClosetEnabled, forKey: CloudClosetEnabledKey)
        defaults.synchronize()
    }
}

//
//  RealmStorageContext.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 28/02/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//

import Foundation
import RealmSwift

/* Storage config options */
public enum ConfigurationType {
    case basic(url: String?)
    case inMemory(identifier: String?)

    var associated: String? {
        get {
            switch self {
            case .basic(let url): return url
            case .inMemory(let identifier): return identifier
            }
        }
    }
}

var Storage: StorageContext! = nil

public func initStorageContext(completion: @escaping () -> ()) {
    do {
        Storage = try RealmStorageContext(configuration: .basic(url: "11LemonsDataAdmin"))
        completion()
    } catch(let error){
        let appError = RealmInitializationError()
        track(error: appError, additionalInfo: appError.errorUserInfo)
    }
}

struct RealmMigrationConfiguration {
    static let currentVersion:UInt64 = 0
    static let migrationBlock: MigrationBlock = { migration, oldSchemaVersion in
        if (oldSchemaVersion < RealmMigrationConfiguration.currentVersion) {
//            take a look to this => https://realm.io/docs/swift/latest/#migrations
            
            // The enumerateObjects(ofType:_:) method iterates
            // over every Person object stored in the Realm file
//            migration.enumerateObjects(ofType: Person.className()) { oldObject, newObject in
//                // combine name fields into a single field
//                let firstName = oldObject!["firstName"] as! String
//                let lastName = oldObject!["lastName"] as! String
//                newObject!["fullName"] = "\(firstName) \(lastName)"
//            }
        }
    }
}

class RealmStorageContext: StorageContext {
    var realm: Realm?
    
    required init(configuration: ConfigurationType = .basic(url: nil)) throws {
        var rmConfig = Realm.Configuration(
            fileURL: Bundle.main.url(forResource: "11LemonsData", withExtension: "realm"),
            schemaVersion: RealmMigrationConfiguration.currentVersion,
            migrationBlock: RealmMigrationConfiguration.migrationBlock)
        
//        rmConfig.readOnly = true
//        switch configuration {
//        case .basic:
//            rmConfig = Realm.Configuration.defaultConfiguration
//            if let url = configuration.associated {
//                rmConfig.fileURL = NSURL(string: url) as URL?
//            }
//        case .inMemory:
//            if let identifier = configuration.associated {
//                rmConfig.inMemoryIdentifier = identifier
//            } else {
//                throw NSError()
//            }
//        }
//        Realm.Configuration.defaultConfiguration = rmConfig
//        try self.realm = Realm(configuration: rmConfig)
        try self.realm = Realm()
    }
    
    public func safeWrite(_ block: (() throws -> Void)) throws {
        guard let realm = self.realm else {
            throw NSError()
        }
        
        if realm.isInWriteTransaction {
            try block()
        } else {
            try realm.write(block)
        }
    }
}


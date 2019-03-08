//
//  AccessToken.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import SwiftyJSON

struct AccessToken {
    
    fileprivate static let ACCESS_TOKEN_KEY = "AccessToken"
    
    let value: String
    
    func save() {
        UserDefaults.standard.set(value, forKey: AccessToken.ACCESS_TOKEN_KEY)
        UserDefaults.standard.synchronize()
    }
    
    static func restore() -> AccessToken? {
        if let accessToken = UserDefaults.standard.object(forKey: AccessToken.ACCESS_TOKEN_KEY) as? String {
            return AccessToken(value: accessToken)
        }
        return nil        
    }
    
    static func clear() {        
        UserDefaults.standard.set(nil, forKey: AccessToken.ACCESS_TOKEN_KEY)
        UserDefaults.standard.synchronize()
    }
    
    static func isExist() -> Bool {
        return UserDefaults.standard.value(forKey: ACCESS_TOKEN_KEY) != nil
    }
}

extension AccessToken: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> AccessToken {
        return AccessToken(value: try j["access_token"].value())
    }
    
}

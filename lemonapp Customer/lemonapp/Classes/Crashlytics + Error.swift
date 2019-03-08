//
//  Crashlytics + Error.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 19/02/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//

import Crashlytics

func track(error: Error, additionalInfo: [String: Any]?) {
    Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: additionalInfo)
}

public class ErrorWithDescription: LocalizedError, CustomNSError {
    let description: String?
    
    init(description: String? = nil) {
        self.description = description
    }
    
    public var errorDescription: String? {
        return self.description
    }
    public var errorUserInfo: [String : Any] {
        if let description = self.description {
            return ["description": description]
        }
        return [:]
    }
}

public class OrderHasNotCreatedByError:ErrorWithDescription {}

public class FindWithIdFailContextFetchError:ErrorWithDescription {}

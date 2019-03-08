//
//  Crashlytics+Error.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 12/02/2019.
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
public class RealmInitializationError:ErrorWithDescription {}
public class SaveAdminOrderRealmError:ErrorWithDescription {}
public class SaveProductsRealmError:ErrorWithDescription {}
public class DeleteAllRealmError:ErrorWithDescription {}
public class SaveAddressRealmError:ErrorWithDescription {}
public class SavePaymentCardRealmError:ErrorWithDescription {}

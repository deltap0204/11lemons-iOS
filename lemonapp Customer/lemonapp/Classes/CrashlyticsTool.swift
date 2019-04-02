//
//  CrashlyticsTool.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 19/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//


import Foundation
import Fabric
import Crashlytics

var crashlyticsTool = CrashlyticsTool()

protocol CrashManagementTool {
    func initialize()
    
    func track(error: Error)
    func track(error: Error, additionalInfo: [String: Any]?)
    
    func leaveBreadcrumb(value:Any?, forEvent:String)
}

final class CrashlyticsTool: CrashManagementTool {
    
    func leaveBreadcrumb(value: Any?, forEvent key: String) {
        self.log(value: value, forEvent: key)
        Crashlytics.sharedInstance().setObjectValue(value, forKey: key)
    }
    
    func initialize() {
        Fabric.with([Crashlytics.self])
    }
    
    func track(error: Error) {
        Crashlytics.sharedInstance().recordError(error)
    }
    
    func track(error: Error, additionalInfo: [String: Any]?) {
        Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: additionalInfo)
    }
    
    private func log(value:Any?, forEvent key: String) {
        if let valueDict = value as? [String: Any] {
            CLSLogv("%@ %@", getVaList([key, valueDict]))
        } else {
            CLSLogv("%@", getVaList([key]))
        }
    }
}


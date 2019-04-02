//
//  EventTracker.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 19/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//

import Foundation

struct NotificationNames {
    struct eventTracker {
        static let realmSaveProduct = Notification.Name("RealmSaveProduct")
        static let realmSaveOrders = Notification.Name("RealmSaveOrders")
    }
}

protocol EventTracker {
    
    func track(event: AnalyticsEvent)
    func trackScreen(screen: AnalyticsScreen)
}

class EventTrackerImpl: EventTracker {

    private let crashManagement: CrashManagementTool = crashlyticsTool
    
    private var userEmailHash: String?

    init() {
        self.trackRealmActivity()
//        self.trackAppEvents()
//        self.trackUserEvents()
        
    }
    
    //MARK : - public
    
    func track(event: AnalyticsEvent) {
        let breadcrum = event.extraData?.prunedForBreadcrum()
        self.crashManagement.leaveBreadcrumb(value: breadcrum, forEvent: event.name)
    }
    
    func trackScreen(screen: AnalyticsScreen) {
        let breadcrum = screen.extraData?.prunedForBreadcrum()
        self.crashManagement.leaveBreadcrumb(value: breadcrum, forEvent: screen.title)
    }
    
    
    func trackViewControllerDidAppear(title: String) {
        self.trackScreen(screen: self.analyticScreenToTrack(title: title, info: nil))
    }
    
    //MARK : - private
    
    private func trackRealmActivity() {
        NotificationCenter.default
            .addObserver(self, selector: #selector(EventTrackerImpl.realmSaveProduct), name: NotificationNames.eventTracker.realmSaveProduct, object: nil)
        
        NotificationCenter.default
            .addObserver(self, selector: #selector(EventTrackerImpl.realmSaveOrders), name: NotificationNames.eventTracker.realmSaveOrders, object: nil)
        
//        listen side menu actions
//        listen order list actions (Dashboard)
//        listen creation of order actions
//        listen pricing screen
//        listen settings
        
    }
    
    func analyticScreenToTrack(title: String, info: String?) -> AnalyticsScreen {
        var extraData = [String: Any]()
        if let infoScreen = info {
            extraData["info"] = infoScreen
        }
        
        return AnalyticsScreen(title:title, extraData: extraData)
    }
    
    //MARK: - Realm
    @objc func realmSaveProduct() {
        let event =  AnalyticsEvent(name: "realm_saveProducts", extraData: nil)
        self.track(event: event)
    }
    
    @objc func realmSaveOrders() {
        let event =  AnalyticsEvent(name: "realm_saveOrders", extraData: nil)
        self.track(event: event)
    }
}

struct AnalyticsEvent {
    var name : String
    var extraData: [String: Any]?
}

struct AnalyticsScreen {
    var title : String
    var extraData: [String: Any]?
}

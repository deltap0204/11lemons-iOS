//
//  SwiftyTimer.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit

final class SwiftyTimer: NSObject {
    
    var timer: Timer? = nil
    
    //let onTimer: SafeSignal<Void> = SafeSignal()
    let onTimer = SafeReplaySubject<Void>()
    
    init (timeInterval: TimeInterval, repeats: Bool) {
        super.init()
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(SwiftyTimer.tick), userInfo: nil, repeats: repeats)
    }
    
    @objc func tick() {
        onTimer.next()
    }    
}

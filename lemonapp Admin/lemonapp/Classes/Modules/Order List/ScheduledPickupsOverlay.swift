//
//  ScheduledPickupsOverlay.swift
//  lemonapp
//
//  Created by Svetlana Dedunovich on 5/4/16.
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


final class ScheduledPickupsOverlay: UIViewController {
    
    typealias OnComplete = () -> Void
    
    var completion: OnComplete?

    @IBOutlet fileprivate weak var walletView: WalletView!
    
    @IBOutlet var pickupLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    
    @IBAction func ok() {
        completion?()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLabel.text = Date().stringWithFormat("hh:mm a")
        
        let preferences = Preferences()
        let dateString = Preferences.nextPickupDateString(preferences.scheduledFrequency, weekday: Int(preferences.scheduledWeekday)!, currentDate: Date())
        pickupLabel.text = "Pickup \(dateString)"
        
        
        if let userWrapper = DataProvider.sharedInstance.userWrapper {
            walletView.viewModel = UserViewModel(userWrapper:userWrapper)
        }
    }
    
    
    static func fromNib() -> ScheduledPickupsOverlay {
        return ScheduledPickupsOverlay(nibName: "ScheduledPickupsOverlay", bundle: nil)
    }
}

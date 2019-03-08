//
//  ReferralViewModel.swift
//  lemonapp
//
//  Created by Svetlana Dedunovich on 5/20/16.
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond


final class ReferralViewModel {
    
    let walletViewModel: Observable<UserViewModel?> = Observable(nil)
    let code:Observable<String?> = Observable(nil)
    
    static let HintPart1 = "1. Friends enter "
    static let HintPart2 = " at sign up.\n\n2. Friends place first order (with $10 off).\n\n3. We add $10 to your wallet. Automatically."

    static let AppStoreLink = "https://appsto.re/us/rHsy_.i"
    
    init() {
        DataProvider.sharedInstance.userWrapperObserver.observeNext { [weak self] in
            if let userWrapper = $0 {
                self?.walletViewModel.value = UserViewModel(userWrapper:userWrapper)
                self?.code.value = userWrapper.referral.value
            }
        }
    }
}

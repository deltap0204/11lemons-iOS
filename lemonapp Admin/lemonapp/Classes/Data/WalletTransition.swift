//
//  WalletTransition.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation

import Bond

enum WalletTransitionType: Int {
    case gift, refund, offer, signDeposit
    
    var image: UIImage? {
        var imageName = ""
        switch self {
        case .gift:
            imageName = "ic_gift"
        case .refund:
            imageName = "ic_refund"
        case .offer:
            imageName = "ic_offer"
        case .signDeposit:
            imageName = "ic_dollar_sign_deposit"
        }
        return UIImage(named: imageName)
    }
}

final class WalletTransition {
    
    var id: Int
    var date: Date?
    var amount: Double
    var reason: String?
    var notes: String?
    var userId: Int
    var type: WalletTransitionType
    var archived: Bool
    let viewed = Observable(false)
    
    init(id: Int,
        date: Date?,
        amount: Double,
        reason: String?,
        notes: String?,
        userId: Int,
        type: WalletTransitionType = .gift,
        archived: Bool) {
            self.id = id
            self.date = date
            self.amount = amount
            self.reason = reason
            self.notes = notes
            self.userId = userId
            self.type = WalletTransitionType.gift
            self.archived = archived
            self.viewed.value = archived
            
            self.viewed.skip(first: 1).observeNext { [weak self] _ in
//                self?.syncDataModel()
            }
    }
}

extension WalletTransition: DashboardItem {
    
    var repeated: Bool {
        return false
    }
    
    var compareDate: Date? {
        return self.date
    }
    
    var dashboardItemType: DashboardItemType {
        return .walletTransition
    }
}

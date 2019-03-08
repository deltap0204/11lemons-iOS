//
//  Wallet.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation

final class Wallet {
    
    var amount: Double
    
    var transitions: [WalletTransition]
    
    init(transitions: [WalletTransition],
        amount: Double) {
            self.transitions = transitions
            self.amount = amount
    }
}

final class NewWallet {
    
    var amount: Double
    
    var transactions: [WalletTransaction]
    
    init(transactions: [WalletTransaction],
         amount: Double) {
        self.transactions = transactions
        self.amount = amount
    }
}

final class WalletTransaction {
    var id: Int
    var date: Date?
    var amount: Double
    var reason: String?
    var userId: Int
    var type: String?
    
    init(id: Int,
         date: Date?,
         amount: Double,
         reason: String?,
         userId: Int,
         type: String?) {
        self.id = id
        self.date = date
        self.amount = amount
        self.reason = reason
        self.userId = userId
        self.type = type
    }
}

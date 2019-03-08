//
//  Wallet+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import SwiftyJSON

extension Wallet: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> Wallet {
        return Wallet.init(
            transitions: try j["wallet"].arrayValue.flatMap { try WalletTransition.decode($0) },
            amount: try j["user"]["WalletAmount"].value()
            )
    }
}

extension NewWallet: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> NewWallet {
        return NewWallet.init(
            transactions: try j["wallet"].arrayValue.flatMap { try WalletTransaction.decode($0) },
            amount: try j["user"]["WalletAmount"].value()
        )
    }
}

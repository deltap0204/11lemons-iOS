//
//  WalletTransition+JSON.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import SwiftyJSON

extension WalletTransition: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> WalletTransition {
        return WalletTransition(
            id: try j["WalletTransactionID"].value(),
            date: Date.fromServerString(j["TransactionDate"].string),
            amount: try j["Amount"].value(),
            reason: j["Reason"].string,
            notes: j["Notes"].string,
            userId: try j["UserID"].value(),
            type: WalletTransitionType(rawValue: j["Type"].intValue) ?? .gift,
            archived: (try? j["Archive"].value()) ?? false)
    }
}

extension WalletTransaction: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> WalletTransaction {
        return WalletTransaction(
            id: try j["WalletTransactionID"].value(),
            date: Date.fromServerString(j["TransactionDate"].string),
            amount: try j["Amount"].value(),
            reason: j["Reason"].string,
            userId: try j["UserID"].value(),
            type: j["WalletType"].string)
    }
}

//
//  WalletTransitionEntity.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//

import Foundation
import RealmSwift
public class WalletTransitionEntity: Object {
    @objc dynamic var id = 0
    @objc dynamic var date: Date? = nil
    @objc dynamic var amount: Double = 0
    @objc dynamic var reason: String? = nil
    
    @objc dynamic var notes: String? = nil
    @objc dynamic var userId = 0
    
    let privateType =  RealmOptional<Int>()
    var type: WalletTransitionType? {
        get {
            if let value = privateType.value {
                return WalletTransitionType(rawValue: value)!
            }
            return nil
        }
        set {
            if let value = newValue {
                privateType.value = value.rawValue
            } else {
                privateType.value = nil
            }
        }
    }
    
    @objc dynamic var archived: Bool = false
    
    static func create(with walletTransition: WalletTransition) -> WalletTransitionEntity {
        let walletTransitionEntity = WalletTransitionEntity()

        walletTransitionEntity.id = walletTransition.id
        walletTransitionEntity.date = walletTransition.date
        walletTransitionEntity.amount = walletTransition.amount
        walletTransitionEntity.reason = walletTransition.reason
        walletTransitionEntity.notes = walletTransition.notes
        walletTransitionEntity.userId = walletTransition.userId
        walletTransitionEntity.type = walletTransition.type
        return walletTransitionEntity
    }
}

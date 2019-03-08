//
//  WalletTransition.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData
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
    
    fileprivate var _dataModel: WalletTransitionModel
    
    init(id: Int,
        date: Date?,
        amount: Double,
        reason: String?,
        notes: String?,
        userId: Int,
        type: WalletTransitionType = .gift,
        archived: Bool,
        dataModel: WalletTransitionModel? = nil) {
            self.id = id
            self.date = date
            self.amount = amount
            self.reason = reason
            self.notes = notes
            self.userId = userId
            self.type = WalletTransitionType.gift
            self.archived = archived
            self._dataModel = dataModel ?? LemonCoreDataManager.findWithId(id) ?? WalletTransitionModel()
            self.viewed.value = _dataModel.viewed || archived
            syncDataModel()
            
            self.viewed.skip(first: 1).observeNext { [weak self] _ in
                self?.syncDataModel()
            }
    }
    
    convenience init(walletTransitionModel: WalletTransitionModel) {
        self.init(id: walletTransitionModel.id.intValue,
            date: walletTransitionModel.date as! Date,
            amount: walletTransitionModel.amount.doubleValue,
            reason: walletTransitionModel.reason,
            notes: walletTransitionModel.notes,
            userId: walletTransitionModel.userId.intValue,
            type: WalletTransitionType(rawValue: (walletTransitionModel.type?.intValue ?? 0)) ?? .gift,
            archived: walletTransitionModel.archived,
            dataModel: walletTransitionModel
        )
    }
}

extension WalletTransition: DataModelWrapper {
    
    var dataModel: NSManagedObject {
        return _dataModel
    }
    
    func syncDataModel() {
        _dataModel.id = NSNumber(value: self.id)
        _dataModel.amount = NSNumber(value: self.amount)
        _dataModel.date = self.date
        _dataModel.reason = self.reason
        _dataModel.notes = self.notes
        _dataModel.userId = NSNumber(value: self.userId)
        _dataModel.type = self.type.rawValue as NSNumber
        _dataModel.archived = self.archived
        _dataModel.viewed = self.viewed.value
        saveDataModelChanges()
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

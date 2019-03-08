//
//  WalletTransitionCellViewModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

final class WalletTransitionCellViewModel: ViewModel {
    
    let amount: String
    let typeName: String?
    let notes: String?
    let transitionTypeImage: UIImage?
    let date: String?
    let shouldAccessoryView: Bool
    var titleColorLabel: UIColor
    var viewed: Bool {
        didSet {
            walletTransition.viewed.value = viewed
            titleColorLabel = walletTransition.viewed.value ? UIColor.white : UIColor.appBlueColor
        }
    }
    
    var walletTransition: WalletTransition
    
    init(walletTransition: WalletTransition) {
        self.walletTransition = walletTransition
        self.date = walletTransition.date?.smartDateString()
        self.amount = walletTransition.amount.asCurrency()
        self.typeName = walletTransition.reason
        self.notes = walletTransition.notes
        self.transitionTypeImage = walletTransition.type.image
        self.shouldAccessoryView = walletTransition.type == .refund
        self.viewed = walletTransition.viewed.value
        self.titleColorLabel = walletTransition.viewed.value ? UIColor.white : UIColor.appBlueColor
    }
}

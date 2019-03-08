//
//  PaymentCardCell.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//


import UIKit
import Bond
import MGSwipeTableCell
import ReactiveKit

protocol PaymentCellViewModel: ViewModel {}

class PaymentCardCellViewModel: PaymentCellViewModel {
    
    let title: String
    let expiration: String
    let cardTypeImage: UIImage?
    let defaultPaymentCard: Observable<PaymentCardProtocol?>
    
    let paymentCard: PaymentCard
    
    init (paymentCard: PaymentCard, defaultPaymentCard: Observable<PaymentCardProtocol?>) {
        self.paymentCard = paymentCard
        self.defaultPaymentCard = defaultPaymentCard
        title = paymentCard.label
        expiration = "exp " + paymentCard.expiration.replacingOccurrences(of: "/", with: " / ")
        cardTypeImage = paymentCard.type.image
    }
}

class PaymentCardCell: MGSwipeTableCell {
    
    static let BUTTON_WIDTH: CGFloat = 60
    static let DELETE_BUTTON_COLOR = UIColor(red: 213/255, green: 0, blue: 0, alpha: 255)
    static let DEFAULT_BUTTON_COLOR = UIColor(red: 0, green: 184/255, blue: 212/255, alpha: 255)
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var expirationLabel: UILabel!
    @IBOutlet fileprivate weak var cardTypeImageView: UIImageView!
    @IBOutlet fileprivate weak var customAccessoryView: UIView!
    var defaultButton: MGSwipeButton
    
    let isUtilsOpen = Observable(false)
    
    required init?(coder aDecoder: NSCoder) {
        let deleteButton = MGSwipeButton(title: "", icon: UIImage(named: "ic_delete"), backgroundColor: AddressCell.DELETE_BUTTON_COLOR)
        deleteButton.buttonWidth = PaymentCardCell.BUTTON_WIDTH
        
        defaultButton = MGSwipeButton(title: "", icon: UIImage(named: "ic_default_off"), backgroundColor: AddressCell.DEFAULT_BUTTON_COLOR)
        defaultButton.setImage(UIImage(named: "ic_default_off"), for: UIControlState())
        defaultButton.setImage(UIImage(named: "ic_default_on"), for: .disabled)
        defaultButton.buttonWidth = PaymentCardCell.BUTTON_WIDTH
        
        super.init(coder: aDecoder)
        
        self.allowsButtonsWithDifferentWidth = true
        self.rightButtons = [defaultButton, deleteButton]
        self.rightSwipeSettings.transition = .clipCenter
    }
    
    var viewModel: PaymentCardCellViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    fileprivate func bindViewModel() {
        
        guard let viewModel = viewModel else { return }
        
        titleLabel.text = viewModel.title
        expirationLabel.text = viewModel.expiration
        cardTypeImageView.image = viewModel.cardTypeImage
        viewModel.defaultPaymentCard.map { [weak viewModel] in $0?.id != viewModel?.paymentCard.id }.bind(to: defaultButton.bnd_enabled)
        viewModel.defaultPaymentCard.map { [weak viewModel] in $0?.id != viewModel?.paymentCard.id }.combineLatest(with: isUtilsOpen).map { $0 || $1 }.observeNext { [weak self] hidden in
            UIView.animate(withDuration: 0.2, animations: {
                self?.customAccessoryView.alpha = hidden ? 0 : 1
            }) 
        }
    }
}

final class ApplePayCardCellViewModel: PaymentCellViewModel {
    
    let defaultPaymentCard: Observable<PaymentCardProtocol?>
    let applePayCard: ApplePayCard
    
    init (applePayCard: ApplePayCard, defaultPaymentCard: Observable<PaymentCardProtocol?>) {
        self.applePayCard = applePayCard
        self.defaultPaymentCard = defaultPaymentCard
    }
}

final class ApplePayCardCell: MGSwipeTableCell {
    
    static let BUTTON_WIDTH: CGFloat = 60
    static let DEFAULT_BUTTON_COLOR = UIColor(red: 0, green: 184/255, blue: 212/255, alpha: 255)
    
    @IBOutlet fileprivate weak var customAccessoryView: UIView!
    var defaultButton: MGSwipeButton
    
    let isUtilsOpen = Observable(false)
    
    fileprivate let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        
        defaultButton = MGSwipeButton(title: "", icon: UIImage(named: "ic_default_off"), backgroundColor: AddressCell.DEFAULT_BUTTON_COLOR)
        defaultButton.setImage(UIImage(named: "ic_default_off"), for: UIControlState())
        defaultButton.setImage(UIImage(named: "ic_default_on"), for: .disabled)
        defaultButton.buttonWidth = ApplePayCardCell.BUTTON_WIDTH
        
        super.init(coder: aDecoder)
        
        self.allowsButtonsWithDifferentWidth = true
        self.rightButtons = [defaultButton]
        self.rightSwipeSettings.transition = .clipCenter
    }
    
    var viewModel: ApplePayCardCellViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    fileprivate func bindViewModel() {
        
        guard let viewModel = viewModel else { return }
        
        viewModel.defaultPaymentCard.map { [weak viewModel] in $0?.id != viewModel?.applePayCard.id }.bind(to: defaultButton.bnd_enabled).dispose(in: disposeBag)
        viewModel.defaultPaymentCard.map { [weak viewModel] in $0?.id != viewModel?.applePayCard.id }.combineLatest(with: isUtilsOpen).map { $0 || $1 }.observeNext { [weak self] hidden in
            UIView.animate(withDuration: 0.2, animations: {
                self?.customAccessoryView.alpha = hidden ? 0 : 1
            }) 
        }.dispose(in: disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag.dispose()
    }
}

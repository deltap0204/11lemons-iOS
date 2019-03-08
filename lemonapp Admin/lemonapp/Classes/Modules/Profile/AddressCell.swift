//
//  AddressCell.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond
import MGSwipeTableCell
import ReactiveKit

final class AddressCellViewModel: ViewModel {
    
    let title: String
    let fullAddress: String
    
    let address: Address
    let defaultAddress: Observable<Address?>
    
    init (address: Address, defaultAddress: Observable<Address?>) {
        self.address = address
        self.defaultAddress = defaultAddress
        title = address.nickname
        fullAddress = address.street + "\n" + address.city + " " + address.zip
    }
    
}

final class AddressCell: MGSwipeTableCell {
    
    static let BUTTON_WIDTH: CGFloat = 60
    static let DELETE_BUTTON_COLOR = UIColor(red: 213/255, green: 0, blue: 0, alpha: 255)
    static let DEFAULT_BUTTON_COLOR = UIColor(red: 0, green: 184/255, blue: 212/255, alpha: 255)
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var addressLabel: UILabel!
    @IBOutlet fileprivate weak var customAccessoryView: UIView!
    let defaultButton: MGSwipeButton
    
    fileprivate let disposeBag = DisposeBag()
    
    let isUtilsOpen = Observable(false)
    
    required init?(coder aDecoder: NSCoder) {
        let deleteButton = MGSwipeButton(title: "", icon: UIImage(named: "ic_delete"), backgroundColor: AddressCell.DELETE_BUTTON_COLOR)
        deleteButton.buttonWidth = AddressCell.BUTTON_WIDTH
        
        defaultButton = MGSwipeButton(title: "", icon: UIImage(named: "ic_default_off"), backgroundColor: AddressCell.DEFAULT_BUTTON_COLOR)
        defaultButton.setImage(UIImage(named: "ic_default_off"), for: UIControlState())
        defaultButton.setImage(UIImage(named: "ic_default_on"), for: .disabled)
        defaultButton.buttonWidth = AddressCell.BUTTON_WIDTH
        
        super.init(coder: aDecoder)
        
        self.allowsButtonsWithDifferentWidth = true
        self.rightButtons = [defaultButton, deleteButton]
        self.rightSwipeSettings.transition = .clipCenter
    }
    
    var viewModel: AddressCellViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    fileprivate func bindViewModel() {
        
        guard let viewModel = viewModel else { return }
        
        titleLabel.text = viewModel.title
        addressLabel.text = viewModel.fullAddress
        viewModel.defaultAddress.map { [weak viewModel] in $0?.id != viewModel?.address.id }.bind(to: defaultButton.bnd_enabled).dispose(in: disposeBag)
        viewModel.defaultAddress.map { [weak viewModel] in $0?.id != viewModel?.address.id }.combineLatest(with: isUtilsOpen).map { $0 || $1 }.observeNext { [weak self] hidden in
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

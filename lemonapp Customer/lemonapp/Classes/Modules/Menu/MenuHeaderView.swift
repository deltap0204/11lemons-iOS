//
//  MenuHeaderView.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

final class MenuHeaderView: UIView {
    
    @IBOutlet fileprivate weak var fullNameLabel: UILabel!
    @IBOutlet fileprivate weak var profilePhotoImageView: UIImageView!
    @IBOutlet fileprivate weak var profilePhotoImageViewContainer: UIView!
    @IBOutlet fileprivate weak var profilePhotoPlaceholderLabel: UILabel!
    @IBOutlet fileprivate weak var button:UIButton!
    @IBOutlet weak var balanceButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!
    let buttonHighlighted = Observable<Bool>(false)
    let buttonSelected = Observable<Bool>(false)
    
    var selected:Bool {
        set {
            button.isSelected = newValue
            buttonSelected.value = newValue
        }
        get {
            return button.isSelected
        }
    }
    
    var viewModel: UserViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    var bnd_tap: SafeSignal<Void> {
        return button.bnd_tap
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let view = Bundle.main.loadNibNamed("MenuHeaderView", owner: self, options: nil)![0] as? UIView {
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.frame = self.bounds
            self.addSubview(view)
            buttonHighlighted.bind(to: button.bnd_highlighted)
            buttonSelected.bind(to: button.bnd_selected)
            
            buttonHighlighted.combineLatest(with: buttonSelected).map { $0 || $1 ? UIColor.appBlueColor :  UIColor(white: 97/255, alpha: 1)}.bind(to: profilePhotoImageViewContainer.bnd_backgroundColor)
            buttonHighlighted.combineLatest(with: buttonSelected).map {  $0 || $1 ? UIColor.appBlueColor :  UIColor.black}.bind(to: fullNameLabel.bnd_textColor)
            buttonHighlighted.combineLatest(with: buttonSelected).map {  $0 || $1 ? UIColor.appBlueColor :  UIColor.appDarkTextColor}.bind(to: balanceLabel.bnd_textColor)
        }
    }
    
    
    fileprivate func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        viewModel.userName.bind(to: fullNameLabel.bnd_text)
        viewModel.balance.bind(to: balanceButton.bnd_title)
        viewModel.photoRequest.bind(to: profilePhotoImageView.bnd_image)
        viewModel.photoPlaceholder.bind(to: profilePhotoPlaceholderLabel.bnd_text)
    }
    
}

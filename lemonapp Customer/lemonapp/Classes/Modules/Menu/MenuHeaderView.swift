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
    
    var disposeBag = DisposeBag()
    
    var selected:Bool {
        set {
            button.isSelected = newValue
            buttonSelected.value = newValue
        }
        get {
            return button.isSelected
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
        self.bindUserWrapper()
    }
    
    
    fileprivate func bindUserWrapper() {
        DataProvider.sharedInstance.userWrapperObserver.observeNext { [weak self] in
            guard let self = self else {return}
            
            if let userWrapper = $0 {
                self.disposeBag = DisposeBag()
                self.fullNameLabel.text = userWrapper.fullName
                userWrapper.walletAmount.map { amount in
                        if let amount = amount {
                            return amount.asCurrency()
                        } else {
                            return "$0.00"
                        }
                    }.bind(to: self.balanceButton.bnd_title).dispose(in: self.disposeBag)
                
                userWrapper.firstName.combineLatest(with: userWrapper.lastName).map {
                    var result = ""
                    if $0.count > 0 {
                        result += $0.substring(to: $0.index($0.startIndex, offsetBy: 1))
                    }
                    if $1.count > 0 {
                        result += $1.substring(to: $0.index($0.startIndex, offsetBy: 1))
                    }
                    return result.uppercased()
                    }.bind(to: self.profilePhotoPlaceholderLabel.bnd_text).dispose(in: self.disposeBag)
                
                userWrapper.profilePhoto.observeNext(with: { [weak self] (imageURL) in
                    guard let self = self else {return}
                    
                    if let cachedImage = ImageCache.getImage(imageURL ?? "profile_photo") {
                        self.profilePhotoImageView.image = cachedImage
                    } else {
                        _ = LemonAPI.getProfileImage(imgURL: imageURL).request().observeNext { [weak self] (resolver: ImageResolver) in
                            guard let self = self else {return}
                            if let image = resolver,
                                let imageURL = imageURL{
                                ImageCache.saveImage(image, url: imageURL).observeNext { _ in
                                    self.profilePhotoImageView.image = resolver
                                }
                            } else {
                                self.profilePhotoImageView.image = resolver
                            }
                        }.dispose(in: self.disposeBag)
                    }
                }).dispose(in: self.disposeBag)
            
            }
        }
    }
}

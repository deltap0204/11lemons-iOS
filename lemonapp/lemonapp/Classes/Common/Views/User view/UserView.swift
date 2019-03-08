//
//  UserView.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond
import ReactiveKit

final class UserViewModel: ViewModel {
    
    let userName: Observable<String?>
    let photoPlaceholder: Observable<String?> = Observable(nil)
    let location = Observable("")
    
    let editMode: Observable<Bool>
    let imgButtonHighlighted = Observable<Bool>(false)
    
    var photoRequest: SafeSignal<UIImage?> {
        
        return SafeSignal/*(replayLength: 1)*/ { [weak self] sink in
            self?.userWrapper.profilePhoto.observeNext { imageURL in
                if let cachedImage = ImageCache.getImage(imageURL ?? "profile_photo") {
                    sink.completed(with: cachedImage)
                } else {
                    _ = LemonAPI.getProfileImage(imgURL: imageURL).request().observeNext { (resolver: ImageResolver) in
                        if let image = resolver,
                        let imageURL = imageURL{
                            ImageCache.saveImage(image, url: imageURL).observeNext { _ in
                                sink.completed(with: resolver)
                            }
                        } else {
                            sink.completed(with: resolver)
                        }
                    }
                }
            }
            //return nil
            return BlockDisposable {}
        }
    }
    
    let balance = Observable<String>("$0.00")
    
    fileprivate let userWrapper: UserWrapper
    
    init (userWrapper: UserWrapper, editMode: Observable<Bool> = Observable(false)) {
        self.userWrapper = userWrapper
        
        userName = Observable(userWrapper.fullName)
        userWrapper.firstName.combineLatest(with: userWrapper.lastName).map {
            var result = ""
            if $0.count > 0 {
                result += $0.substring(to: $0.index($0.startIndex, offsetBy: 1))
            }
            if $1.count > 0 {
                result += $1.substring(to: $0.index($0.startIndex, offsetBy: 1))
            }
            return result.uppercased()
            }.bind(to: photoPlaceholder)
        
        userWrapper.walletAmount.map { amount in
            if let amount = amount {
                return amount.asCurrency()
            } else {
                return "$0.00"
            }
        }.bind(to: balance)
        
        self.editMode = editMode

        self.editMode.observeNext { [weak self] _ in
            self?.userName.value = self?.userWrapper.fullName
        }

        userName.observeNext { [weak userWrapper] in
            
            if let userName = $0?.components(separatedBy: " "), userName.count > 1,
                let firstName = userName.first,
                let lastName = userName.last {
                    userWrapper?.firstName.value = firstName
                    userWrapper?.lastName.value = lastName
            }
        }
        
        userWrapper.defaultAddress.observeNext { [weak self] in
            if let city = $0?.city, !city.isEmpty,
                let state = $0?.state, !state.isEmpty {
                    self?.location.value = city + ", " + state
            } else {
                self?.location.value = ""
            }
        }
    }
}

@IBDesignable
final class UserView : UIView {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet fileprivate weak var locationButton: UIButton!
    @IBOutlet fileprivate weak var imageButton: UIButton!
    @IBOutlet fileprivate weak var profilePhotoPlaceholderLabel: UILabel!
    @IBOutlet fileprivate weak var cameraImageView: UIImageView!
    
    @IBOutlet fileprivate weak var photoView: UIImageView!
    
    @IBOutlet fileprivate weak var balanceLabel: UIButton!
    
    weak var delegate: UserViewDelegate? {
        didSet {
            cameraImageView.isHidden = delegate == nil
        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if let view = Bundle.main.loadNibNamed("UserView", owner: self, options: nil)![0] as? UIView {
            addSubview(view)
            addConstraint(NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
            
            //            imageButton.bnd_highlighted.observeNext { [weak cameraImageView] in
            //                cameraImageView?.isHighlighted = $0
            //            }
            
            
            imageButton.bnd_tap.observeNext { [weak imageButton] in
                imageButton?.isSelected = true
            }
        }
    }
    
    var viewModel: UserViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    fileprivate func bindViewModel() {
        
        guard let viewModel = viewModel else { return }
        
        viewModel.userName.bidirectionalBind(to: nameTextField.bnd_text)
        viewModel.location.bind(to: locationButton.bnd_title)
        viewModel.location.observeNext { [weak self] in
            self?.locationButton.isEnabled = $0.count > 0
        }
        
        viewModel.photoRequest.bind(to: photoView.bnd_image)
        
        viewModel.imgButtonHighlighted.bind(to: imageButton.bnd_highlighted)
        viewModel.imgButtonHighlighted.observeNext { [weak cameraImageView] in
            cameraImageView?.isHighlighted = $0
        }
        
        imageButton.bnd_tap.observeNext { [weak self] in
            if let strongRef = self {
                strongRef.delegate?.userViewDidTapImage(strongRef)
            }
        }
        viewModel.editMode.bind(to: self.nameTextField.bnd_enabled)
        viewModel.photoPlaceholder.bind(to: profilePhotoPlaceholderLabel.bnd_text)
        cameraImageView.isHidden = delegate == nil
        
        viewModel.balance.bind(to: balanceLabel.bnd_title)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let hitView = super.hitTest(point, with: event)
        
        if hitView == self || hitView == self.subviews.first {
            return nil
        }
        
        return hitView
    }
}

extension UserView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.delegate?.nameTextFieldShouldReturn(textField) ?? true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.range(of: " ") != nil && string == " " {
            return false
        }
        return true
    }
}

protocol UserViewDelegate: NSObjectProtocol {
    func userViewDidTapImage(_ userView: UserView)
    func nameTextFieldShouldReturn(_ textField: UITextField) -> Bool
}

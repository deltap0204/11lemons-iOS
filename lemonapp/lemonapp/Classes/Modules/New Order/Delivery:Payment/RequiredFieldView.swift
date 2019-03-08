//
//  RequiredFieldView.swift
//  lemonapp
//
//  Created by Svetlana Dedunovich on 4/27/16.
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond
import ReactiveKit

private enum RequiredFieldState {
    case createNew, select, error, success
    
    var icon: UIImage {
        switch self {
        case .createNew:
            return UIImage(assetIdentifier: UIImage.AssetIdentifier.PlusCircle)
        case .select:
            return UIImage(assetIdentifier: UIImage.AssetIdentifier.BottomArrow)
        case .error:
            return UIImage(assetIdentifier: UIImage.AssetIdentifier.ValidationError)
        case .success:
            return UIImage(assetIdentifier: UIImage.AssetIdentifier.ValidationSuccess)
        }
    }
    
    
    var normalColor: UIColor {
        switch self {
        case .error:
            return UIColor.attentionColor
        default:
            return UIColor.white
        }
    }
    
    
    var highlightedColor: UIColor {
        return UIColor.appBlueColor
    }
    
    var isTemporaryState: Bool {
        switch self {
        case .error, .success:
            return true
        default:
            return false
        }
    }
    
    var hideErrorText: Bool {
        return self != .error
    }
}


final class RequiredFieldView: UIView {
    
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconView: UIImageView!

    @IBOutlet var selectButton: UIButton!
    
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var specialImageView: UIImageView!
    @IBOutlet var valueLeadingConstraint: NSLayoutConstraint?
    
    let valueLabelText = Observable<String?>(nil)
    let specialImage = Observable<UIImage?>(nil)
    let disposeBag = DisposeBag()
    fileprivate var state = RequiredFieldState.createNew {
        willSet {
            if newValue.isTemporaryState {
                if state !=  newValue {
                    previousState = state
                }
                let timer = Timer(fireAt: Date(timeIntervalSinceNow: 1), interval: 0.0, target: self, selector: #selector(RequiredFieldView.backToPermanentState), userInfo: nil, repeats: false)
                RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
            }
        }
        didSet {
            updateView()
        }
    }
    
    fileprivate var previousState: RequiredFieldState?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        errorLabel?.textColor = UIColor.attentionColor
        
        valueLabelText.bind(to: valueLabel.bnd_text).dispose(in:self.disposeBag)
        if specialImageView != nil {
            specialImage.bind(to: specialImageView.bnd_image).dispose(in:self.disposeBag)
        }
        
        //valueLabel.bnd_text.observeNext { [weak self] text in
        valueLabelText.observeNext { [weak self] text in
            if text?.count == 0 {
                self?.state = RequiredFieldState.createNew
            } else {
                self?.state = RequiredFieldState.select
            }
        }.dispose(in:self.disposeBag)
        
        //TODO migration-check
        //Before migration code
        
        /*
        selectButton.bnd_controlEvent.map { (event) -> UIColor? in
            if ([UIControlEvents.touchUpInside, UIControlEvents.touchUpOutside].contains(event)) {
                return self.state.normalColor
            } else if ([UIControlEvents.touchDown].contains(event)) {
                return self.state.highlightedColor
            }
            return nil
        }.filter { $0 != nil }.observeNext { color in
            self.iconView.tintColor = color
            
            [self.valueLabel, self.titleLabel].forEach { label in
                label.textColor = color
            }
    
        }
 */
        
        selectButton.bnd_controlEvent(UIControlEvents.touchUpInside).observeNext { (event) in
            self.iconView.tintColor = self.state.normalColor
            [self.valueLabel, self.titleLabel].forEach { label in
                label.textColor = self.state.normalColor
            }
        }.dispose(in:self.disposeBag)
        
        selectButton.bnd_controlEvent(UIControlEvents.touchUpOutside).observeNext { (event) in
            self.iconView.tintColor = self.state.normalColor
            [self.valueLabel, self.titleLabel].forEach { label in
                label.textColor = self.state.normalColor
            }
        }.dispose(in:self.disposeBag)
        
        selectButton.bnd_controlEvent(UIControlEvents.touchDown).observeNext { (event) in
            self.iconView.tintColor = self.state.highlightedColor
            [self.valueLabel, self.titleLabel].forEach { label in
                label.textColor = self.state.highlightedColor
            }
        }.dispose(in:self.disposeBag)
        
        specialImage.skip(first: 1).observeNext { image in
            if let _ = image {
                self.valueLeadingConstraint?.constant = 175
            } else {
                self.valueLeadingConstraint?.constant = 105
            }
            self.setNeedsLayout()
        }.dispose(in:self.disposeBag)
    }
    
    func showSuccess() {
        state = .success
    }
    
    
    func showError() {
        state = .error
    }
    
    @objc func backToPermanentState() {
        if let permanentState = previousState {
            state = permanentState
        }
    }
    
    fileprivate func updateView() {
        iconView.image = state.icon
        titleLabel.textColor = state.normalColor
        errorLabel.isHidden = state.hideErrorText
    }
}

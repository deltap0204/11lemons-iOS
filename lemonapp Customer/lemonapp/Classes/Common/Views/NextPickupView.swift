//
//  NextPickupView.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation

class NextPickupView: UIView {
    fileprivate static let RotateAnimationKey = "NextPickupViewRotation"

    @IBOutlet fileprivate weak var spinnerView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var subTitleLabel: UILabel!
    
    @IBOutlet fileprivate weak var mainLabel: UILabel!
    @IBOutlet fileprivate weak var valueTextField: UITextField!
    @IBOutlet fileprivate weak var spinner: UIActivityIndicatorView!
    
    convenience init () {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        if let view = Bundle.main.loadNibNamed("NextPickupView", owner: self, options: nil)![0] as? UIView {
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.frame = self.bounds
            view.cornerRadius = view.frame.height / 2
            self.addSubview(view)
        }
        
        backgroundColor = UIColor.clear
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(NextPickupView.startEditing))
        self.addGestureRecognizer(tapGestureRecognizer)
        
        setViewState(.normal)

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(TextFieldWithPicker.actionDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(TextFieldWithPicker.actionCancel))
        
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        valueTextField.inputAccessoryView = toolbar
    }
    
    @objc func actionDone() {
        setViewState(.loading)
        var newValue = Int(valueTextField.text ?? "45") ?? 45
        newValue = newValue < 0 ? 0 : newValue
        _ = LemonAPI.setPickupETA(pickupETA: newValue).request().observeNext { [weak self] (_: EventResolver<String>) in
            DataProvider.sharedInstance.refreshPickupETA()
            self?.setViewState(.normal)
        }
    }
    
    @objc func actionCancel() {
        setViewState(.normal)
    }
    
    func setTitle(_ title: String, subtitle: String, allowEditing: Bool = false) {
        titleLabel.text = title
        subTitleLabel.text = subtitle
        if valueTextField.isHidden {
            valueTextField.text = title
        }
        self.isUserInteractionEnabled = allowEditing
    }
    
    func stopAnimation() {
        if spinnerView.layer.animationKeys()?.contains(NextPickupView.RotateAnimationKey) ?? false {
            spinnerView.layer.removeAnimation(forKey: NextPickupView.RotateAnimationKey)
        }
    }
    
    func startAnimation() {
        stopAnimation()
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Float(M_PI * 2.0)
        rotationAnimation.duration = 3.0
        rotationAnimation.repeatCount = Float.infinity
        spinnerView.layer.add(rotationAnimation, forKey: NextPickupView.RotateAnimationKey)
    }
    
    @objc func startEditing() {
        setViewState(.editing)
    }
}

extension NextPickupView {
    fileprivate enum ViewState {
        case normal, editing, loading
    }
    
    fileprivate func setViewState(_ state: ViewState) {
        mainLabel.isHidden = state != .normal
        valueTextField.isHidden = state != .editing
        spinner.isHidden = state != .loading
        if (state == .editing) {
            valueTextField.becomeFirstResponder()
        } else {
            valueTextField.resignFirstResponder()
        }
    }
}

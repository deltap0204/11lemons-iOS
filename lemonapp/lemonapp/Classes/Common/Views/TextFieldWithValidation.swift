//
//  TextFieldWithValidation.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond

enum TextFieldValidState: Equatable {
    case valid
    case checking
    case invalid(message: String)
    case checked
    case none
    
    func message() -> String? {
        switch self {
        case .invalid(let message):
            return message
        default:
            return nil
        }
    }
    
    fileprivate var id: Int {
        switch self {
        case .invalid:
            return 2
        case .checked:
            return 4
        case .valid:
            return 1
        case .none:
            return 0
        case .checking:
            return 5
        }
    }
    
    func image() -> UIImage? {
        switch self {
        case .invalid:
            return UIImage(assetIdentifier: .ValidationError)
        case .checked:
            return UIImage(assetIdentifier: .ValidationSuccess)
        default:
            return nil
        }
    }
    
    func color() -> UIColor {
        switch self {
        case .invalid:
            return UIColor(red: 213/255, green: 0, blue: 0, alpha: 1)
        case .checked:
            return UIColor(red: 0, green: 184/255, blue: 212/255, alpha: 1)
        default:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
}

func == (left: TextFieldValidState, right: TextFieldValidState) -> Bool {
    return left.id == right.id
}

typealias Validator = (_ text: String?) throws -> Bool
typealias ValidationExecuter = () -> Bool

final class TextFieldWithValidation: UIView {
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.bnd_controlEvent(UIControlEvents.editingDidEnd).observeNext { [weak self] in
                if self?.text?.isEmpty == false {
                        self?.validate()
                    }
            }
            textField.bnd_controlEvent(UIControlEvents.editingDidBegin).observeNext { [weak self] in
                    self?.state.value = TextFieldValidState.none
            }
        }
    }
    @IBOutlet fileprivate weak var detailsLabel: UILabel!
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var loadingIndicator: UIActivityIndicatorView!
    
    let loadingIndicatorHidden = Observable<Bool>(false)
    
    var bnd_text: DynamicSubject<String?>{
        return textField.bnd_text
    }
    
    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    fileprivate var _validator: Validator? = nil
    
    var validator: Validator? {
        get {
            return _validator
        }
    }
    
    func setValidator(_ validator: @escaping Validator) -> ValidationExecuter {
        _validator = validator
        return { [weak self] in return self?.validate() ?? false }
    }
    
    fileprivate func validate() -> Bool {
        guard state.value != .valid && state.value != .checking && state.value != .checked else { return true }
        do {
            if let validator = self.validator {
                if try validator(self.text) {
                    self.state.value = TextFieldValidState.valid
                    return true
                } else {
                    self.state.value = TextFieldValidState.invalid(message: "Invalid")
                }
            }
        } catch let error as ErrorWithDescriptionType {
            self.state.value = TextFieldValidState.invalid(message: error.message)
        } catch {
            self.state.value = TextFieldValidState.invalid(message: "Invalid")
        }
        return false
    }
    
    var state = Observable(TextFieldValidState.none)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadingIndicatorHidden.bind(to: self.loadingIndicator.bnd_hidden)
        
        state.observeNext { [weak self] in
            guard self?.detailsLabel != nil && self?.imageView != nil else { return }
            self?.detailsLabel.text = $0.message()
            self?.detailsLabel.textColor = $0.color()
            self?.imageView.image = $0.image()
            self?.loadingIndicatorHidden.next($0 != .checking)
        }
        
        loadingIndicatorHidden.observeNext { [weak loadingIndicator] in
            if !$0 {
                loadingIndicator?.startAnimating()
            } else {
                loadingIndicator?.stopAnimating()
            }
        }
    }
    
}


//
//  PaymentCardDetailsViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond
import Braintree
import ReactiveKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


enum PaymentCardError:String, ErrorWithDescriptionType {
    case InvalidLabel = "Label Required"
    
    var title: String {
        return ""
    }
    
    var message: String {
        return self.rawValue
    }
}

final class PaymentCardDetailsViewModel: ViewModel {
    
    let cardNumber: Observable<String?>
    let expDate: Observable<String?>
    let cvc: Observable<String?>
    let type: Observable<PaymentCardType>
    let cvcPlaceholder: Observable<String?> = Observable(nil)
    let zip: Observable<String?>
    
    let isAddedMode: Observable<Bool>
 
    fileprivate let paymentCard: PaymentCard
    fileprivate let changedPaymentCard: PaymentCard
    fileprivate let userWrapper: UserWrapper
    
    let backButtonTitle: String
    
    init (userWrapper: UserWrapper, paymentCard: PaymentCard? = nil, backButtonTitle: String = "") {
        self.userWrapper = userWrapper
        self.paymentCard = paymentCard ?? PaymentCard(userId: userWrapper.id)
        self.backButtonTitle = backButtonTitle
  
        expDate = Observable(self.paymentCard.expiration)
        cvc = Observable(self.paymentCard.secCode)
        type = Observable(self.paymentCard.type)
        isAddedMode = Observable(paymentCard == nil)
        zip = Observable(self.paymentCard.billingAddress?.zip)
        
        changedPaymentCard = self.paymentCard.copy()
        
        if isAddedMode.value {
            cardNumber = Observable(self.paymentCard.number)
            cardNumber.observeNext { [weak self] in
                self?.changedPaymentCard.number = $0?.replacingOccurrences(of: " ", with: "") ?? ""
                self?.type.value = (self?.changedPaymentCard.type ?? .None)
            }
        } else {
            var cardNumberStr = ""
            paymentCard?.type.numberPattern.dropLast().forEach { cardNumberStr += "*" * $0 + " " }
            cardNumber = Observable(cardNumberStr + self.paymentCard.number)
        }
        
        zip.observeNext {
            self.changedPaymentCard.billingAddress?.zip = $0 ?? ""
        }
        type.observeNext { [weak self] in
            // autocorrection of the cvcLength for CardType
//            if let cvc = self?.cvc.value {
//                self?.cvc.value = cvc.splitWithPattern([$0.cvcLength]).first)
//            }
            self?.cvcPlaceholder.value = "*" * $0.cvcLength
        }
        
        expDate.observeNext { [weak self] in
            self?.changedPaymentCard.expiration = $0 ?? ""
        }
        cvc.observeNext { [weak self] in
            self?.changedPaymentCard.secCode = $0 ?? ""
        }
    }
    
    func reset() {
        expDate.value = paymentCard.expiration
        cvc.value = paymentCard.secCode
        zip.value = paymentCard.billingAddress?.zip
        type.value = paymentCard.type
        if isAddedMode.value {
            cardNumber.value = paymentCard.number
        } else {
            var cardNumberStr = ""
            self.paymentCard.type.numberPattern.dropLast().forEach { cardNumberStr += "*" * $0 + " " }
            cardNumber.value = cardNumberStr + self.paymentCard.number
        }
    }
    
    //TODO: validation
    fileprivate func validate() throws -> Bool {
        return true
    }
    
    var saveChanges: Action<() throws -> PaymentCard> {
        return Action { [weak self] in
            Signal/*(replayLength: 1)*/ { [weak self] sink in
                do {
                    try self?.validate()
                    if let isAddedMode = self?.isAddedMode.value,
                        let paymentCard = self?.changedPaymentCard {
                        let isDefault = self?.userWrapper.defaultAddress.value == nil
                        if isAddedMode {
                            if let token = DataProvider.sharedInstance.paymentToken, let braintreeClient = BTAPIClient(authorization: token) {
                                let cardClient = BTCardClient(apiClient: braintreeClient)
                                let card = BTCard(number: paymentCard.number, expirationMonth: paymentCard.expMonth, expirationYear: paymentCard.expYear, cvv: paymentCard.secCode)
                                card.shouldValidate = true
                                cardClient.tokenizeCard(card) { (tokenizedCard, error) in
                                    if let error = error {
                                        sink.completed(with:  { throw LemonError.invalideCard })
                                        return
                                    }
                                    if let tokenized = tokenizedCard {
                                        paymentCard.token = tokenized.nonce
                                        _ = LemonAPI.addPaymentCard(paymentCard: paymentCard)
                                            .request().observeNext { (resultResolver: EventResolver<PaymentCard>) in
                                                do {
                                                    let paymentCard = try resultResolver()
                                                    paymentCard.saveDataModel()
                                                    self?.userWrapper.paymentCards.value.append(paymentCard)
                                                    if isDefault {
                                                        if let userWrapper = self?.userWrapper {
                                                            userWrapper.defaultPaymentCard.value = paymentCard
                                                            _ = LemonAPI.editProfile(user: userWrapper.changedUser).request().observeNext { (userResolver :EventResolver<User>) in
                                                                do {
                                                                    defer {
                                                                        sink.completed(with: {
                                                                            return paymentCard
                                                                        })
                                                                    }
                                                                    let user = try userResolver()
                                                                    self?.userWrapper.saveChanges()
                                                                    
                                                                } catch { }
                                                            }
                                                        } else {
                                                            sink.completed(with: {
                                                                return paymentCard
                                                            })
                                                        }
                                                    } else {
                                                        sink.completed(with: {
                                                            return paymentCard
                                                        })
                                                    }
                                                    
                                                } catch let error {
                                                    sink.completed(with:  { throw error } )
                                                }
                                        }
                                    } else {
                                        sink.completed(with: { throw LemonError.unableToGetCardToken })
                                    }
                                }
                            }
                            else {
                                sink.completed(with:  { throw LemonError.unableToGetCardToken })
                            }
                            
                        } else {
                            _ = LemonAPI.editPaymentCard(paymentCard: paymentCard)
                                .request().observeNext { (resultResolver: EventResolver<PaymentCard>) in
                                    do {
                                        let paymentCard = try resultResolver()
                                        self?.paymentCard.sync(paymentCard)
                                        if isDefault &&
                                            (self?.userWrapper.defaultPaymentCard.value as? PaymentCard) != paymentCard {
                                            if let userWrapper = self?.userWrapper {
                                                userWrapper.defaultPaymentCard.value = self?.paymentCard
                                                _ = LemonAPI.editProfile(user: userWrapper.changedUser).request().observeNext { (userResolver :EventResolver<User>) in
                                                    do {
                                                        defer {
                                                            sink.completed(with: {
                                                                return paymentCard
                                                            })
                                                        }
                                                        try userResolver()
                                                        self?.userWrapper.saveChanges()
                                                        
                                                    } catch { }
                                                }
                                            } else {
                                                sink.completed(with: {
                                                    return paymentCard
                                                })
                                            }
                                        } else {
                                            sink.completed(with: {
                                                return paymentCard
                                            })
                                        }
                                    } catch let error {
                                        sink.completed(with:  { throw error } )
                                    }
                            }
                        }
                    }
                } catch let error {
                    sink.completed(with:  { throw error } )
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
}

final class PaymentCardDetailsViewController: UIViewController {
    
    @IBOutlet fileprivate weak var cardNumberTextField: UITextField!
    @IBOutlet fileprivate weak var expDateTextField: UITextField!
    @IBOutlet fileprivate weak var cvcTextField: UITextField!
    @IBOutlet fileprivate weak var zipTextField: UITextField!
    @IBOutlet fileprivate weak var backButton: UIButton!
    
    @IBOutlet fileprivate weak var typeImageView: UIImageView!
    
    @IBOutlet fileprivate weak var labelTrailingConstaint1: NSLayoutConstraint!
    @IBOutlet fileprivate weak var labelTrailingConstaint2: NSLayoutConstraint!
    
    @IBOutlet var doneBtn: HighlightedButton!
    @IBOutlet var doneBtnHeight: NSLayoutConstraint!
    
    fileprivate var cardNumberTextFieldDisposable: Disposable?
    
    var onResultHandler: ((_ result: AnyObject?) -> ())?
    
    var viewModel: PaymentCardDetailsViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: doneBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: doneBtn)
        bindViewModel()
    }
    
    fileprivate func bindViewModel() {
        guard viewModel != nil && isViewLoaded else { return }
        
        viewModel?.type.observeNext { [weak self] in self?.typeImageView.image = $0.image }
        
        viewModel?.isAddedMode.observeNext { [weak self] in
            self?.title = $0 ? "Add Card" : "Edit Card"
            self?.cvcTextField.isEnabled = $0
            self?.cardNumberTextField.isEnabled = $0
            self?.expDateTextField.isEnabled = $0
            self?.expDateTextField.isEnabled = $0
            if !$0 { // editing mode
                self?.cardNumberTextField.text = self?.viewModel?.cardNumber.value
                self?.typeImageView.image = self?.viewModel?.paymentCard.type.image
            } else { // add
                self?.cardNumberTextFieldDisposable = self?.cardNumberTextField.bnd_text.map { $0?.replacingOccurrences(of: " ", with: "") }.bind(to: self!.viewModel!.cardNumber)
                self?.cardNumberTextField.text = self?.viewModel?.cardNumber.value
            }
        }
        
        self.expDateTextField.text =  viewModel?.expDate.value?.replacingOccurrences(of: "/", with: " / ")
        self.expDateTextField.bnd_text.observeNext { [weak self] in
            self?.viewModel?.expDate.value = $0?.replacingOccurrences(of: " ", with: "")
        }
        viewModel?.cvc.bidirectionalBind(to: cvcTextField.bnd_text)
        
        viewModel?.cvcPlaceholder.bind(to: self.cvcTextField.bnd_placeholder)
        
        viewModel?.zip.bidirectionalBind(to: self.zipTextField.bnd_text)
        backButton.titleLabel?.text = viewModel?.backButtonTitle
        backButton.sizeToFit()
    }
    
    @IBAction func cancel(_ sender: AnyObject?) {
        viewModel?.reset()
        self.expDateTextField.text =  viewModel?.expDate.value?.replacingOccurrences(of: "/", with: " / ")
        self.cardNumberTextField.text = self.viewModel?.cardNumber.value
    }
    
    @IBAction func save(_ sender: AnyObject?) {
        showLoadingOverlay()
        viewModel?.saveChanges.execute {  [weak self] in
            do {
                defer {
                    self?.viewModel?.userWrapper.refresh()
                }
                let result = try $0()
                let parentAlertView = self?.navigationController?.parent?.view ?? self?.parent?.navigationController?.view
                AlertView().showInView(parentAlertView)
                self?.returnResult(result)
            } catch let error as ErrorWithDescriptionType {
                self?.handleError(error)
            } catch let error {
                print(error)
            }
            hideLoadingOverlay()
        }
    }
}

extension PaymentCardDetailsViewController: KeyboardListenerProtocol {

    func getAboveKeyboardView() -> UIView? {
        return zipTextField
    }
}

extension PaymentCardDetailsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let tvNext = textField as? TextFieldWithNext {
            tvNext.nextTextField?.becomeFirstResponder()
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == cardNumberTextField ||
            textField == expDateTextField ||
            textField == cvcTextField ||
            textField == zipTextField {
                
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let deleting = newText.count < textField.text?.count
            
            var stripppedNumber = newText.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: newText.startIndex ..< newText.endIndex)
            let digits = stripppedNumber.count
            let startIndex = stripppedNumber.startIndex
            let selectedRange = textField.selectedTextRange
            let oldLength = textField.text?.count ?? 0
            var result = ""
            
                
            if textField == cardNumberTextField {
                
                self.viewModel?.cardNumber.value = stripppedNumber
                let numberLength = self.viewModel?.type.value.numberLength ?? PaymentCardType.DEFAULT_NUMBER_LENGTH
                let numberPattern = self.viewModel?.type.value.numberPattern ?? PaymentCardType.DEFAULT_NUMBER_PATTERN
                
                if digits > numberLength {
                    
                    //TODO migration-check
                    
                    //Before migration code
                    //stripppedNumber = stripppedNumber.substring(to: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: numberLength))
                   
                    //Possible fix
                    stripppedNumber = stripppedNumber.substring(to: numberLength)
                }
                
                result = stripppedNumber.splitWithPattern(numberPattern).joined(separator: " ")
                
                if digits >= numberLength {
                    textField.text = result
                    textFieldShouldReturn(textField)
                }
            } else if (textField == expDateTextField) {
                
                if digits > 4 {
                    
                    //TODO migration-check
                    
                    //Before migration code
                    //stripppedNumber = stripppedNumber.substring(to: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 4))
                    
                    //Possible fix
                    stripppedNumber = stripppedNumber.substring(to: 4)
                    
                }
                if digits == 0 {
                    result = ""
                } else if (digits < 2 || (digits == 2 && deleting)) {
                    result = stripppedNumber
                } else {
                    
                    //TODO migration-check
                    
                    //Before migration code
                    //result = stripppedNumber.substring(to: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 2)) + " / " + stripppedNumber.substring(from: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 2))
                    
                    //Possible fix
                    result = stripppedNumber.substring(to: 2) + " / " + stripppedNumber.substring(from: 2)
                    
                }
                if digits >= 4 {
                    textField.text = result
                    textFieldShouldReturn(textField)
                }
            } else if (textField == cvcTextField) {
                
                let numberLength = self.viewModel?.type.value.cvcLength ?? PaymentCardType.DEFAULT_CVC_LENGTH
                if digits > numberLength {
                    
                    //TODO migration-check
                    
                    //Before migration code
                    //stripppedNumber = stripppedNumber.substring(to: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: numberLength))
                    
                    //Possible fix
                    stripppedNumber = stripppedNumber.substring(to: numberLength)
                    
                }
                result = stripppedNumber
                if digits >= numberLength {
                    textField.text = result
                    textFieldShouldReturn(textField)
                }
            } else if (textField == zipTextField) {
                
                if digits > 5 {
                    //TODO migration-check
                    
                    //Before migration code
                    //stripppedNumber = stripppedNumber.substring(to: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 5))
                    
                    //Possible fix
                    stripppedNumber = stripppedNumber.substring(to: 5)
                    
                }
                result = stripppedNumber
                if digits >= 5 {
                    textField.text = result
                    textFieldShouldReturn(textField)
                }
            }
            textField.text = result
            
            if let selectedRange = selectedRange {
                
                var offset = -oldLength + (textField.text?.count ?? 0)
                offset = offset == 0 && string.isEmpty ? -range.length : offset
                let newPosition = textField.position(from: selectedRange.end , offset:offset) ?? UITextRange().start
                let newRange = textField.textRange(from: newPosition, to:newPosition)
                textField.selectedTextRange = newRange
            }
            return false
        }
        return true
    }
}

extension PaymentCardDetailsViewController: ViewControllerForResult {
    func popViewController() {
        let navController = self.navigationController ?? self.parent?.navigationController
        navController?.popViewController(animated: true)
    }
    
    override func onBack(_ sender: AnyObject?) {
        returnResult(nil)
    }
}

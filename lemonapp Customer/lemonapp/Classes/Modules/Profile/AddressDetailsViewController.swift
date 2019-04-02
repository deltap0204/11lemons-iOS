//
//  AddressDetailsViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

import CoreLocation
import AddressBookUI
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


enum AddressDetailsError:String, ErrorWithDescriptionType {
    case InvalidLabel = "Label Required"
    case InvalidZipCode = "Invalid Zip code"
    
    var title: String {
        return ""
    }
    
    var message: String {
        return self.rawValue
    }
}

final class AddressDetailsViewModel: ViewModel {
    
    let title: Observable<String?>
    let isDefault: Observable<Bool>
    let street: Observable<String?>
    let aptUnit: Observable<String?>
    let zip: Observable<String?>
    
    var location: LocationData? = nil
    
    let notes: Observable<String?>
    
    let isAddedMode: Observable<Bool>
    
    fileprivate let address: Address
    fileprivate let changedAddress: Address
    fileprivate let userWrapper: UserWrapper
    
    let backButtonTitle: String
    
    init (userWrapper: UserWrapper, address: Address? = nil, backButtonTitle: String = "") {
        self.userWrapper = userWrapper
        self.address = address ?? Address(userId: userWrapper.id)
        self.backButtonTitle = backButtonTitle
        
        title = Observable(self.address.nickname)
        isDefault = Observable(userWrapper.defaultAddress.value?.id == self.address.id)
        street = Observable(self.address.street)
        aptUnit = Observable(self.address.aptSuite)
        zip = Observable(self.address.zip)
        notes = Observable(self.address.notes)
        self.isAddedMode = Observable(address == nil)
        
        changedAddress = self.address.copy()
        title.observeNext { [weak self] in self?.changedAddress.nickname = $0 ?? "" }
        street.observeNext { [weak self] in self?.changedAddress.street = $0 ?? "" }
        aptUnit.observeNext { [weak self] in self?.changedAddress.aptSuite = $0 ?? "" }
        zip.observeNext { [weak self] in self?.changedAddress.zip = $0 ?? "" }
        notes.observeNext { [weak self] in self?.changedAddress.notes = $0 }
        isDefault.observeNext { [weak self] in
            if $0 {
                self?.userWrapper.defaultAddress.value = self?.changedAddress
            } else {
                self?.userWrapper.refresh()
            }
        }
    }
    
    fileprivate func validate() throws -> Bool {
        let titleVal = title.value?.trimmingCharacters(in: CharacterSet(charactersIn: " ")) ?? ""
        if titleVal.isEmpty {
            throw AddressDetailsError.InvalidLabel
        }
        if zip.value?.count < 5 || location == nil {
            throw AddressDetailsError.InvalidZipCode
        }
        return true
    }
    
    var locationRequest: Action<() throws -> ()> {
        return Action { [weak self] in
            Signal { [weak self] sink in
                if let zip = self?.zip.value {
                    
                    _ = LemonAPI.validateZip(zip: zip).request().observeNext { (resolver: EventResolver<[LocationData]>) in
                        do {
                            guard let location = try resolver().first else {
                                sink.completed(with: { throw AddressDetailsError.InvalidZipCode })
                                self?.location = nil
                                return
                            }
                            self?.changedAddress.city = location.city
                            self?.changedAddress.state = location.state
                            self?.userWrapper.defaultAddress.value = self?.userWrapper.defaultAddress.value
                            self?.location = location
                            sink.completed(with: { })
                        } catch let error {
                            self?.location = nil
                            sink.completed(with: { throw error })
                        }
                    }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    var saveChanges: Action<() throws -> Address> {
        return Action { [weak self] in
            Signal/*(replayLength: 1)*/ { [weak self] sink in
                do {
                    try self?.validate()
                    if let isAddedMode = self?.isAddedMode.value,
                        let address = self?.changedAddress,
                        let isDefault = self?.isDefault.value {
                            if isAddedMode {
                                _ = LemonAPI.addAddress(address: address)
                                    .request().observeNext { (addressResolver: EventResolver<Address>) in
                                        do {
                                            let resultAddress = try addressResolver()
                                            DataProvider.sharedInstance.refreshAddresses()
                                            self?.userWrapper.addresses.value.append(resultAddress)
                                            if isDefault {
                                                if let userWrapper = self?.userWrapper {
                                                    userWrapper.defaultAddress.value = resultAddress
                                                    _ = LemonAPI.editProfile(user: userWrapper.changedUser).request().observeNext { (userResolver :EventResolver<User>) in
                                                        do {
                                                            defer {
                                                                sink.completed(with: {
                                                                    return resultAddress
                                                                })
                                                            }
                                                            let user = try userResolver()
                                                            self?.userWrapper.saveChanges()
                                                            
                                                        } catch {}
                                                    }
                                                } else {
                                                    sink.completed(with: {
                                                        return resultAddress
                                                    })
                                                }
                                            } else {
                                                sink.completed(with: {
                                                    return resultAddress
                                                })
                                            }
                                        } catch let error {
                                            sink.completed(with:  { throw error } )
                                        }
                                }
                            } else {
                                _ = LemonAPI.editAddress(address: address)
                                    .request().observeNext { (addressResolver: EventResolver<Address>) in
                                        do {
                                            let resultAddress = try addressResolver()
                                            self?.address.sync(resultAddress)
                                            if isDefault {
                                                if let userWrapper = self?.userWrapper {
                                                    userWrapper.defaultAddress.value = self?.address
                                                    _ = LemonAPI.editProfile(user: userWrapper.changedUser).request().observeNext { (userResolver :EventResolver<User>) in
                                                        do {
                                                            defer {
                                                                sink.completed(with: {
                                                                    return resultAddress
                                                                })
                                                            }
                                                            try userResolver()
                                                            self?.userWrapper.saveChanges()
                                                        } catch {}
                                                    }
                                                } else {
                                                    sink.completed(with: {
                                                        return resultAddress
                                                    })
                                                }
                                            } else {
                                                sink.completed(with: {
                                                    return resultAddress
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

final class AddressDetailsViewController: UIViewController {
    
    @IBOutlet fileprivate weak var labelTextField: UITextField!
    @IBOutlet fileprivate weak var streetTextField: UITextField!
    @IBOutlet fileprivate weak var aptUnitTextField: UITextField!
    @IBOutlet fileprivate weak var zipTextField: UITextField!
    @IBOutlet fileprivate weak var notesTextView: UITextView!
    @IBOutlet fileprivate weak var backButton: UIButton!
    
    @IBOutlet var saveBtn: HighlightedButton!
    @IBOutlet var saveBtnHeight: NSLayoutConstraint!
    
    var viewModel: AddressDetailsViewModel? {
        didSet {
            bindViewModel()
        }
    }
    fileprivate let disposeBag = DisposeBag()
    var onResultHandler: ((_ result: AnyObject?) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        streetTextField.delegate = self
        zipTextField.delegate = self
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: saveBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: saveBtn)
        bindViewModel()
    }
    
    fileprivate func bindViewModel() {
        guard viewModel != nil && isViewLoaded else { return }
        
        viewModel?.isAddedMode.observeNext { [weak self] in
            self?.title = $0 ? "New Address" : "Edit Address"
        }
        
        viewModel?.title.bidirectionalBind(to: labelTextField.bnd_text)
        viewModel?.street.bidirectionalBind(to: streetTextField.bnd_text)

        
//        streetTextField.bnd_text.observeNext { [weak self] (newText) in
//            if let text = newText {
//                if text.contains(" ") {
//                        self?.streetTextField.keyboardType = .default
//                    return
//                }
//            }
//            self?.streetTextField.keyboardType = .numbersAndPunctuation
//        }.dispose(in: disposeBag)

        viewModel?.aptUnit.bidirectionalBind(to: aptUnitTextField.bnd_text)
        viewModel?.zip.bidirectionalBind(to: zipTextField.bnd_text)
        
        
        zipTextField.bnd_focused.observeNext { [weak self] focused in
            if !focused {
                let textCount = self?.zipTextField.text?.count
                if textCount == 5 {
                    showLoadingOverlay()
                    self?.viewModel?.locationRequest.execute {
                        do {
                            let _ = try $0()
                        } catch let error as ErrorWithDescriptionType {
                            self?.handleError(error)
                        } catch {}
                        hideLoadingOverlay()
                    }
                }
            }
        }
        
        viewModel?.notes.bidirectionalBind(to: notesTextView.bnd_text)
        backButton.titleLabel?.text = viewModel?.backButtonTitle
        backButton.sizeToFit()
    }
    
    @IBAction func save(_ sender: AnyObject? = nil) {
        showLoadingOverlay()
        viewModel?.saveChanges.execute {  [weak self] in
            do {
                defer {
                    self?.viewModel?.userWrapper.refresh()
                }
                let result = try $0()
                let parentViewController = self?.navigationController?.parent ?? self?.parent?.navigationController
                AlertView().showInView(parentViewController?.view)
                if self?.viewModel?.location?.allowReg != true {
                    self?.returnResult(nil)
                    parentViewController?.handleError(LemonError.unavailableLocation)
                } else {
                    self?.returnResult(result)
                }
            } catch let error as ErrorWithDescriptionType {
                self?.handleError(error)
            } catch let error {
                print(error)
            }
            hideLoadingOverlay()
        }
    }
}

extension AddressDetailsViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.rangeOfCharacter(from: CharacterSet.newlines) == nil {
            return true
        }
        textView.resignFirstResponder()
        return false
    }

}

extension AddressDetailsViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == streetTextField {
            if let text = textField.text,
                let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                if updatedText.contains(" ") {
                    self.streetTextField.keyboardType = .default
//                    streetTextField.resignFirstResponder()
//                    streetTextField.becomeFirstResponder()
                    return true
                }
                
                self.streetTextField.keyboardType = .numbersAndPunctuation
//                streetTextField.resignFirstResponder()
//                streetTextField.becomeFirstResponder()
                return true
            }
        }
        if (textField == zipTextField) {
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            var stripppedNumber = newText.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: newText.startIndex ..< newText.endIndex)
            let digits = stripppedNumber.count
            
            if digits >= 5 {
                stripppedNumber = stripppedNumber.substring(to: 5)
                zipTextField.text = stripppedNumber
                textField.resignFirstResponder()
                return false
            }
        }
        
        return true
    }
    
}

extension AddressDetailsViewController: KeyboardListenerProtocol {

    func getAboveKeyboardView() -> UIView? {
        return notesTextView
    }
}

extension AddressDetailsViewController: ViewControllerForResult {
    func popViewController() {
        let navController = self.navigationController ?? self.parent?.navigationController
        navController?.popViewController(animated: true)
    }
    
    override func onBack(_ sender: AnyObject?) {
        DataProvider.sharedInstance.userWrapper?.refresh()
        returnResult(nil)
    }
}

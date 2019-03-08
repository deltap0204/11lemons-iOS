//
//  ProfileInfoViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond
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


enum ProfileInfoError:String, Error {
    case InvalidEmail = "Invalid email"
    case InvalidPassword = "Password should contain at least 4 characters"
    case InvalidMobilePhone = "Invalid mobile phone"
    
    var message: String {
        return self.rawValue
    }
}

final class ProfileInfoViewModel: ViewModel {
    
    let email: Observable<String?> = Observable("")
    let password: Observable<String?> = Observable("")
    let mobilePhone: Observable<String?> = Observable("")
    let defaultAddress = Observable("")
    let defaultPaymentCard = Observable("")
    let defaultPaymentCardImage: Observable<UIImage?> = Observable(nil)
    let startMobilePhone: String
    
    var addressesSegue: StoryboardSegueIdentifier = .Addresses
    var paymentSegue: StoryboardSegueIdentifier = .PaymentCards
    
    fileprivate let userWrapper: UserWrapper
    fileprivate let router: ProfileRouter
    
    let editMode: Observable<Bool> = Observable(false)
    
    let editButtonTitle = Observable("Edit")
    let signOutButtonTitle = Observable("Sign Out")
    
    let addressesViewModel: AddressesViewModel
    let paymentCardsViewModel: PaymentCardsViewModel
    
    var addressDetailsViewModel: AddressDetailsViewModel {
        return AddressDetailsViewModel(userWrapper: self.userWrapper)
    }
    var paymentCardDetailsViewModel: PaymentCardDetailsViewModel {
        return PaymentCardDetailsViewModel(userWrapper: self.userWrapper)
    }
    
    init(userWrapper: UserWrapper, router: ProfileRouter) {
        self.userWrapper = userWrapper
        email.bidirectionalBind(to: userWrapper.email)
        mobilePhone.bidirectionalBind(to: userWrapper.mobilePhone)
        startMobilePhone = userWrapper.changedUser.mobilePhone
        
        self.router = router
        self.addressesViewModel = AddressesViewModel(userWrapper: userWrapper)
        self.paymentCardsViewModel = PaymentCardsViewModel(userWrapper: userWrapper)
        
        editMode.observeNext { [weak self] in
            self?.editButtonTitle.value = $0 ? "Cancel" : "Edit"
            self?.signOutButtonTitle.value = $0 ? "Save" : "Done"
        }
        userWrapper.defaultAddress.observeNext { [weak self] in
            self?.defaultAddress.value = $0?.nickname != nil ? $0!.nickname + " (Default)" : ""
        }
        userWrapper.defaultPaymentCard.observeNext { [weak self] in
            self?.defaultPaymentCard.value = $0?.label ?? ""
            self?.defaultPaymentCardImage.value = $0?.lightImage
        }
    }
    
    func refresh() {
        userWrapper.refresh()
        password.value = ""
        addressesSegue = self.userWrapper.activeAddresses.count > 0 ? .Addresses : .Address
        paymentSegue = self.userWrapper.activePaymentCards.count > 0 || ApplePayCard.isApplePayAvailable() ? .PaymentCards : .PaymentCard
    }
    
    func validate() throws -> Bool {
        let emailVal = email.value ?? ""
        let mobilePhoneVal = mobilePhone.value ?? ""
        let passwordLength = (password.value ?? "").count
        if !emailVal.isEmail {
            throw ProfileInfoError.InvalidEmail
        }
        if !mobilePhoneVal.isMobilePhone {
            throw ProfileInfoError.InvalidMobilePhone
        }
        if passwordLength < 4 && passwordLength > 0 {
            throw ProfileInfoError.InvalidPassword
        }
        return true
    }
    
    func goToOrders() {
        router.showOrders()
    }
    
    func onEdit() {
        editMode.value = !editMode.value
    }
    
    var saveChanges: Action<() throws -> User> {
        return Action { [weak self] in
            Signal { [weak self] sink in
                if let changedUser = self?.userWrapper.changedUser {
                    _ = LemonAPI.editProfile(user: changedUser)
                        .request().observeNext { (userResolver: EventResolver<User>) in
                            do {
                                let user = try userResolver()
                                self?.userWrapper.saveChanges()
                                let passwordVal = self?.password.value ?? ""
                                if passwordVal.count > 3 {
                                    _ = LemonAPI.chagePassword(password: passwordVal)
                                        .request().observeNext { (resultResolver:EventResolver<Void>) in
                                            do {
                                                try resultResolver()
                                                _ = LemonAPI.userPassword = passwordVal
                                                sink.completed(with: {
                                                    return user
                                                })
                                            } catch let error {
                                                sink.completed(with:  { throw error } )
                                            }
                                    }
                                } else {
                                    sink.completed(with: {
                                        return user
                                    })
                                }
                            } catch let error {
                                self?.userWrapper.refresh()
                                sink.completed(with:  { throw error } )
                            }
                    }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
}

final class ProfileInfoViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    @IBOutlet fileprivate weak var mobilePhoneTextField: UITextField!
    @IBOutlet fileprivate weak var defaultAddressLabel: UILabel!
    @IBOutlet fileprivate weak var defaultPaymentCardLabel: UILabel!
    @IBOutlet fileprivate weak var defaultPaymentCardImage: UIImageView!
    @IBOutlet fileprivate weak var addressesButton: UIButton!
    @IBOutlet fileprivate weak var paymentButton: UIButton!
    
    @IBOutlet fileprivate weak var menuItem: UIBarButtonItem!
    @IBOutlet fileprivate weak var rightItem: UIBarButtonItem!
    @IBOutlet fileprivate weak var doneButton: UIButton!
    
    @IBOutlet var doneBtnHeight: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var profileInfoContainer: UIScrollView!
    

    var viewModel: ProfileInfoViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: doneBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: doneButton)
        bindViewModel()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.profileInfoContainer.alpha = 1
        viewModel?.refresh()
    }
        
    fileprivate func bindViewModel() {
    
        guard viewModel != nil && isViewLoaded else { return }

        viewModel?.editButtonTitle.bind(to: rightItem.bnd_title)
        viewModel?.signOutButtonTitle.bind(to: doneButton.bnd_title)
        
        doneButton.bnd_tap.observeNext { [weak self] in
            
            if let viewModel = self?.viewModel {
                if viewModel.editMode.value {
                    do {
                        if try viewModel.validate() {
                            showLoadingOverlay()
                            viewModel.saveChanges.execute { [weak self] resolver in
                                do {
                                    defer {
                                        self?.viewModel?.onEdit()
                                    }
                                    try resolver()
                                } catch let error as BackendError {
                                    self?.handleError(error)
                                } catch let error {
                                    print(error)
                                }
                                hideLoadingOverlay()
                            }
                        }
                        
                    } catch let error as ProfileInfoError {
                        self?.showAlert("Sorry", message: error.message)
                    } catch {}
                    return
                } else {
                    DataProvider.sharedInstance.userWrapper = viewModel.userWrapper;
                }
            }
            self?.viewModel?.goToOrders()            
        }
        
        viewModel?.email.bidirectionalBind(to: emailTextField.bnd_text)
        viewModel?.editMode.bind(to: emailTextField.bnd_enabled)
        viewModel?.password.bidirectionalBind(to: passwordTextField.bnd_text)
        viewModel?.editMode.bind(to: passwordTextField.bnd_enabled)
        viewModel?.mobilePhone.bidirectionalBind(to: mobilePhoneTextField.bnd_text)
        viewModel?.editMode.observeNext { [weak self] in
            if let mobile = self?.mobilePhoneTextField.text {
                self?.mobilePhoneTextField.isEnabled = $0 || mobile.isEmpty
            }
        }
        viewModel?.defaultAddress.bind(to: defaultAddressLabel.bnd_text)
        viewModel?.defaultPaymentCard.bind(to: defaultPaymentCardLabel.bnd_text)
        viewModel?.defaultPaymentCardImage.bind(to: defaultPaymentCardImage.bnd_image)
        
        addressesButton.bnd_tap.observeNext { [weak self] in
            let isEditMode = self?.viewModel?.editMode.value ?? false
            if !isEditMode {
                if let segue = self?.viewModel?.addressesSegue {
                    self?.performSegueWithIdentifier(segue)
                }
            } else {
                self?.showAlert("Sorry", message: "Please, save changes to continue")
            }
        }
        paymentButton.bnd_tap.observeNext { [weak self] in
            let isEditMode = self?.viewModel?.editMode.value ?? false
            if !isEditMode {
                if let segue = self?.viewModel?.paymentSegue {
                    self?.performSegueWithIdentifier(segue)
                }
            } else {
                self?.showAlert("Sorry", message: "Please, save changes to continue")
            }
        }
        
    }
    
    
    @IBAction func onEditButton(_ sender: AnyObject?) {
        
        if let editMode = viewModel?.editMode.value {
            if editMode {
                self.viewModel?.refresh()
                self.viewModel?.onEdit()
            } else {
                viewModel?.onEdit()
            }
        }
    }
    
    @IBAction func openMenu(_ sender: UIBarButtonItem) {
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addressesVC = segue.destination as? AddressesViewController {
            addressesVC.viewModel = viewModel?.addressesViewModel
        } else if let addressDetailsVC = segue.destination as? AddressDetailsViewController {
            addressDetailsVC.viewModel = viewModel?.addressDetailsViewModel
        } else if let paymentCardsVC = segue.destination as? PaymentCardsViewController {
            paymentCardsVC.viewModel = viewModel?.paymentCardsViewModel
        } else if let paymentCardDetailsVC = segue.destination as? PaymentCardDetailsViewController {
            paymentCardDetailsVC.viewModel = viewModel?.paymentCardDetailsViewModel
        }
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.profileInfoContainer.alpha = 0
        }) 
    }
}

extension ProfileInfoViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let tf = textField as? TextFieldWithNext {
            tf.nextTextField?.becomeFirstResponder()
            return false
        }
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == self.mobilePhoneTextField) {
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
                let deleting = newText.count < textField.text?.count
            
            var stripppedNumber = newText.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: newText.startIndex ..< newText.endIndex)
            let digits = stripppedNumber.count
            
            let startIndex = stripppedNumber.startIndex
            if digits > 10 {
                //TODO migration-check
                
                //Before migration code
                //stripppedNumber = stripppedNumber.substringToIndex(startIndex.advancedBy(10))
                
                //After migration
                    //stripppedNumber = stripppedNumber.substring(to: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 10))
                
                //Possible fix
                stripppedNumber = stripppedNumber.substring(to: 10)
            }
            let selectedRange = textField.selectedTextRange
            let oldLength = textField.text?.count ?? 0
            var result = ""
            if digits == 0 {
                result = ""
            } else if (digits < 3 || (digits == 3 && deleting)) {
                result = "(" + stripppedNumber
            } else if (digits < 6 || (digits == 6 && deleting)) {
                //TODO migration-check
                
                //Before migration code
                /*
                result = "(" + stripppedNumber.substring(to: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 3)) + ") " + stripppedNumber.substring(from: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 3))
 */
                
                //Possible fix
                result = "(" + stripppedNumber.substring(to: 3) + ") " + stripppedNumber.substring(from: 3)
                
            } else {
                //TODO migration-check
                
                //Before migration code
                
//                result = "(" + stripppedNumber.substring(to: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 3)) + ") " + stripppedNumber.substring(with: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 3) ..< <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 6)) + "-" + stripppedNumber.substring(from: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 6))
                
                //Possible fix
                result = "(" + stripppedNumber.substring(to: 3) + ") " + stripppedNumber.substring(with: stripppedNumber.index(from: 3)..<stripppedNumber.index(from: 6)) + "-" + stripppedNumber.substring(from: 6)
            }
            textField.text = result
            
            if let selectedRange = selectedRange {
                
                let offset = -oldLength + (textField.text?.count ?? 0)
                let newPosition = textField.position(from: selectedRange.end , offset:offset) ?? UITextRange().start
                let newRange = textField.textRange(from: newPosition, to:newPosition)
                textField.selectedTextRange = newRange
            }
            if digits >= 10 {
                textField.resignFirstResponder()
                if let viewModel = self.viewModel {
                    if result.isMobilePhone && viewModel.startMobilePhone.isEmpty && !viewModel.editMode.value {                                                showLoadingOverlay()
                        viewModel.saveChanges.execute { [weak self] in
                            do {
                                defer {
                                    hideLoadingOverlay()
                                    textField.isEnabled = false
                                }
                                try $0()
                            } catch let error as BackendError {
                                self?.handleError(error)
                            } catch let error {
                                print(error)
                            }
                        }
                    }
                }
            }
            return false;
        }  else if textField == emailTextField && string == " " {
            return false
        }
        return true;
    }
}

extension ProfileInfoViewController: KeyboardListenerProtocol {

    func getAboveKeyboardView() -> UIView? {
        return mobilePhoneTextField
    }
    
    /*
    var holdNavigationBar: Bool {
        return true
    }
 */
}

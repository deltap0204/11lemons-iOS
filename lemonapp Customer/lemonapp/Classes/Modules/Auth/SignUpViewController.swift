//
//  SignUpViewController.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
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

enum SignUpValidationError: String, ErrorWithDescriptionType {
    
    case InvalidFirstName = "Please enter your First name"
    case InvalidLastName = "Please enter your Last name"
    case InvalidEmail = "Please enter a valid email"
    case InvalidPassword = "Password should contain at least 4 characters"
    case InvalidMobilePhone = "Please enter a valid mobile phone"
    case InvalidZipCode = "Please enter a valid zip code"
    case InvalidPromoCode = "Please enter a valid promo code"
    case InvalidEntry = "Invalid Entry"
    
    var title: String {
        return ""
    }
    
    var message: String {
        return self.rawValue
    }
}

final class SignUpViewModel: ViewModel {
    let email: Observable<String?> = Observable(UserDefaults.standard.value(forKey: NSUserDefaultsDataKeys.LatestEmailAddress.rawValue) as? String)
    let password: Observable<String?> = Observable(nil)
    let firstName: Observable<String?> = Observable(nil)
    let lastName: Observable<String?> = Observable(nil)
    let mobilePhone: Observable<String?> = Observable(nil)
    let zipCode: Observable<String?> = Observable(nil)
    let referralCode: Observable<String?> = Observable(nil)
    var zipcCodeLocation: LocationData? = nil
    
    let emailValidator: Validator = {
        if $0 != nil && $0!.isEmail {
            return true
        }
        throw SignUpValidationError.InvalidEmail
    }
    
    let passwordValidator: Validator = {
        if $0 != nil && $0!.count >= 4 {
            return true
        }
        throw SignUpValidationError.InvalidPassword
    }
    
    let mobileValidator: Validator = {
        if $0 != nil && $0!.isMobilePhone {
            return true
        }
        throw SignUpValidationError.InvalidMobilePhone
    }
    
    let firstNameValidator: Validator = {
        if $0 != nil && !$0!.isEmpty {
            return true
        }
        throw SignUpValidationError.InvalidLastName
    }
    
    let lastNameValidator: Validator = {
        if $0 != nil && !$0!.isEmpty {
            return true
        }
        throw SignUpValidationError.InvalidLastName
    }
    
    let zipCodeValidator: Validator = {
        if $0 != nil && $0!.count == 5 {
            return true
        }
        throw SignUpValidationError.InvalidZipCode
    }
    
    let referralCodeValidator: Validator = {
        if $0 != nil && !$0!.isEmpty {
            return true
        } else if $0 == nil || $0!.isEmpty {
            return true
        }
        throw SignUpValidationError.InvalidPromoCode
    }
    var validatorExecuters = [ValidationExecuter]()
    
    func validation() -> Bool {
        return validatorExecuters.map { $0() }.reduce(true) { $0 && $1 }
    }
    
    func storeLatestEmail() {
        if let email = self.email.value, email.isEmail {
            let ud = UserDefaults.standard
            ud.setValue(email, forKey: NSUserDefaultsDataKeys.LatestEmailAddress.rawValue)
            ud.synchronize()
        }
    }
    
    //typealias SingUpResolver = () throws -> (User, LocationData)
    typealias SingUpResolver = EventResolver<(User, LocationData)>
    
    var signUpRequest: Action<SingUpResolver> {
        return Action { [weak self] in
            Signal/*(replayLength: 1)*/ { [weak self] sink in
                guard let strongSelf = self else { return /*nil*/ BlockDisposable {} }
                guard strongSelf.validation() else { return BlockDisposable{} }
                
                guard let firstNameVal = strongSelf.firstName.value,
                    let lastNameVal = strongSelf.lastName.value,
                    let emailVal = strongSelf.email.value,
                    let passwordVal = strongSelf.password.value,
                    let mobilePhoneVal = strongSelf.mobilePhone.value,
                    let zipCodeVal = strongSelf.zipCode.value
                    else {
                        sink.completed(with:  { throw SignUpValidationError.InvalidEntry } )
                        return BlockDisposable{}
                }
                
                guard let location = self?.zipcCodeLocation else {
                    sink.completed(with:  { throw SignUpValidationError.InvalidZipCode } )
                    return BlockDisposable{}
                }

                if let referralCodeVal = strongSelf.referralCode.value, referralCodeVal.count > 0 {
                    _ = LemonAPI.checkReferral(referralCode: referralCodeVal).request().observeNext { (resolver: EventResolver<String>) in
                        do {
                            let referredById = Int(try resolver())
                            self?.signupWithCompletion(firstNameVal, lastNameVal: lastNameVal, emailVal: emailVal, passwordVal: passwordVal, mobilePhoneVal: mobilePhoneVal, zipCode: zipCodeVal, referralCode: referralCodeVal, referredById: referredById, location: location, sink: sink)
                        }  catch {
                            sink.completed(with:  { throw SignUpValidationError.InvalidEntry } )
                        }
                    }
                } else {
                    self?.signupWithCompletion(firstNameVal, lastNameVal: lastNameVal, emailVal: emailVal, passwordVal: passwordVal, mobilePhoneVal: mobilePhoneVal, zipCode: zipCodeVal, referralCode: nil, referredById: nil, location: location, sink: sink)
                }
                
                return BlockDisposable{}
            }
        }
    }
    
    typealias SignUpObserver = AtomicObserver<() throws -> (User, LocationData), NSError>
    
    fileprivate func signupWithCompletion(_ firstNameVal: String, lastNameVal: String, emailVal: String, passwordVal: String, mobilePhoneVal: String, zipCode: String, referralCode: String?, referredById: Int?, location: LocationData, sink: SignUpObserver) {
        _ = LemonAPI.signUp(
            firstName: firstNameVal,
            lastName: lastNameVal,
            email: emailVal,
            password: passwordVal,
            mobilePhone: mobilePhoneVal,
            zipCode: zipCode,
            referralCode: referralCode,
            referredById:  referredById
            ).request().observeNext { (userResolver: EventResolver<User>) in
                do {
                    let user = try userResolver()
                    user.saveDataModel()
                    LemonAPI.userId = user.id
                    LemonAPI.userPassword = passwordVal
                    sink.completed(with:  {return (user, location) })
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        LemonAPI.startSession(userId: user.id, email: emailVal, password: passwordVal)
                            .request().observeNext { (tokenResolver: EventResolver<AccessToken>) in
                                do {
                                    let token = try tokenResolver()
                                    saveToken(token: token)
                                    self.storeLatestEmail()
                                } catch let error {
                                    sink.completed(with:  { throw error } )
                                }
                        }
                    }
                    
                } catch let error {
                    sink.completed(with:  { throw error } )
                }
        }
    }
    
    var checkEmail: Action<() throws -> Bool> {
        return Action { [weak self] in
            return Signal { sink in
                if let email = self?.email.value {
                    _ = LemonAPI.checkEmail(email: email).request().observeNext { (resolver: EventResolver<Void>) in
                        do {
                            try resolver()
                            sink.completed(with:  {return true })
                        } catch let error {
                            sink.completed(with:  {throw error })
                        }
                    }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    var checkPhone: Action<() throws -> Bool> {
        return Action { [weak self] in
            return Signal { sink in
                if let phone = self?.mobilePhone.value {
                    _ = LemonAPI.checkPhone(phone: phone).request().observeNext { (resolver: EventResolver<Void>) in
                        do {
                            try resolver()
                            sink.completed(with:  {return true })
                        } catch let error {
                            sink.completed(with:  {throw error })
                        }
                    }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    var checkReferralCode: Action<() throws -> Bool> {
        return Action { [weak self] in
            return Signal { sink in
                if let referralCode = self?.referralCode.value {
                    _ = LemonAPI.checkReferral(referralCode: referralCode).request().observeNext { (resolver: @escaping EventResolver<String>) in
                        sink.completed(with:  {return Int(try resolver().lowercased()) != nil  })
                    }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    var checkZipCode: Action<() throws -> Bool> {
        return Action { [weak self] in
            return Signal { sink in
                self?.zipcCodeLocation = nil
                if let zipCode = self?.zipCode.value {
                    
                    _ = LemonAPI.validateZip(zip: zipCode).request().observeNext { (resolver: EventResolver<[LocationData]>) in
                        if let location = (try? resolver())?.first {
                            self?.zipcCodeLocation = location
                            sink.completed(with:  {return true })
                        }  else {
                            sink.completed(with:  { throw SignUpValidationError.InvalidZipCode } )
                        }
                    }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
}

final class SignUpViewController: UIViewController {
    
    @IBOutlet fileprivate weak var emailTextField: TextFieldWithValidation!
    @IBOutlet fileprivate weak var passwordTextField: TextFieldWithValidation!
    @IBOutlet weak var firstNameTextField: TextFieldWithValidation!
    @IBOutlet fileprivate weak var lastNameTextField: TextFieldWithValidation!
    @IBOutlet fileprivate weak var mobilePhoneTextField: TextFieldWithValidation!
    @IBOutlet fileprivate weak var zipCodeTextField: TextFieldWithValidation!
    @IBOutlet fileprivate weak var referralCodeTextField: TextFieldWithValidation!
    
    @IBOutlet fileprivate weak var joinButton: ActivityButton!
    
    var viewModel = SignUpViewModel()
    var disposeBag = DisposeBag()
    var authRouter: AuthRouter!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.authRouter = AuthRouter()
        // to handle keyboard shortcut replacement will "bind" model to textfield in delegae
        emailTextField.bnd_text.bind(to: viewModel.email)
        self.viewModel.password.bidirectionalBind(to: passwordTextField.bnd_text)
        self.viewModel.firstName.bidirectionalBind(to: firstNameTextField.bnd_text)
        self.viewModel.lastName.bidirectionalBind(to: lastNameTextField.bnd_text)
        self.viewModel.mobilePhone.bidirectionalBind(to: mobilePhoneTextField.bnd_text)
        self.viewModel.zipCode.bidirectionalBind(to: zipCodeTextField.bnd_text)
        self.viewModel.referralCode.bidirectionalBind(to: referralCodeTextField.bnd_text)
        
        viewModel.validatorExecuters.append(emailTextField.setValidator(viewModel.emailValidator))
        viewModel.validatorExecuters.append(mobilePhoneTextField.setValidator(viewModel.mobileValidator))
        viewModel.validatorExecuters.append(firstNameTextField.setValidator(viewModel.firstNameValidator))
        viewModel.validatorExecuters.append(lastNameTextField.setValidator(viewModel.lastNameValidator))
        viewModel.validatorExecuters.append(zipCodeTextField.setValidator(viewModel.zipCodeValidator))
        viewModel.validatorExecuters.append(passwordTextField.setValidator(viewModel.passwordValidator))
        viewModel.validatorExecuters.append(referralCodeTextField.setValidator(viewModel.referralCodeValidator))
        
        firstNameTextField.textField.bnd_focused.filter { !$0 }.combineLatest(with: firstNameTextField.state).observeNext { [weak firstNameTextField] in
            if $1 == .valid {
                firstNameTextField?.state.next(.checked)
            }
        }.dispose(in: disposeBag)
        
        lastNameTextField.textField.bnd_focused.filter { !$0 }.combineLatest(with: lastNameTextField.state.filter { $0 == .valid }).observeNext { [weak lastNameTextField] in
            if $1 == .valid {
                lastNameTextField?.state.next(.checked)
            }
        }.dispose(in: disposeBag)
        
        passwordTextField.textField.bnd_focused.filter { !$0 }.combineLatest(with: passwordTextField.state.filter { $0 == .valid }).observeNext { [weak passwordTextField] in
            if $1 == .valid {
                passwordTextField?.state.next(.checked)
            }
        }.dispose(in: disposeBag)
        
        emailTextField.textField.bnd_focused.combineLatest(with: emailTextField.state).observeNext { [weak self] in
            if !$0 && $1 == TextFieldValidState.valid {
                self?.emailTextField.state.next(.checking)
                self?.viewModel.checkEmail.execute {
                    do {
                        if try $0() {
                            self?.emailTextField.state.value = .checked
                        }
                    } catch let error as ErrorWithDescriptionType {
                        self?.emailTextField.state.value = .invalid(message: error.message)
                    } catch {}
                }
            }
        }.dispose(in: disposeBag)
        
        mobilePhoneTextField.textField.bnd_focused.combineLatest(with: mobilePhoneTextField.state).observeNext { [weak self] in
            if !$0 && $1 == TextFieldValidState.valid {
                self?.mobilePhoneTextField.state.next(.checking)
                self?.viewModel.checkPhone.execute {
                    do {
                        if try $0() {
                            self?.mobilePhoneTextField.state.value = .checked
                        }
                    } catch let error as ErrorWithDescriptionType {
                        self?.mobilePhoneTextField.state.value = .invalid(message: error.message)
                    } catch {}
                }
            }
        }.dispose(in: disposeBag)
        
        referralCodeTextField.textField.bnd_focused.combineLatest(with: referralCodeTextField.state).observeNext { [weak self] in
            if !$0 && $1 == TextFieldValidState.valid && self?.referralCodeTextField.text?.isEmpty == false {
                self?.referralCodeTextField.state.next(.checking)
                self?.viewModel.checkReferralCode.execute {
                    do {
                        if try $0() {
                            self?.referralCodeTextField.state.value = .checked
                        } else {
                            self?.referralCodeTextField.state.value = .invalid(message: "")
                        }
                    } catch let error as ErrorWithDescriptionType {
                        self?.referralCodeTextField.state.value = .invalid(message: error.message)
                    } catch {}
                }
            }
        }.dispose(in: disposeBag)
        
        zipCodeTextField.textField.bnd_focused.combineLatest(with: zipCodeTextField.state).observeNext { [weak self] in
            if !$0 && $1 == TextFieldValidState.valid {
                self?.zipCodeTextField.state.next(.checking)
                self?.viewModel.checkZipCode.execute {
                    do {
                        if try $0() {
                            self?.zipCodeTextField.state.value = .checked
                        } else {
                            self?.zipCodeTextField.state.value = .invalid(message: SignUpValidationError.InvalidZipCode.message)
                        }
                    } catch let error as ErrorWithDescriptionType {
                        self?.zipCodeTextField.state.value = .invalid(message: error.message)
                    } catch {}
                }
            }
        }.dispose(in: disposeBag)
        
        referralCodeTextField.state.map { $0.color() }.bind(to: referralCodeTextField.textField.bnd_textColor)
        
        joinButton.bnd_tap.observeNext { [weak self] in
            self?.signUp()
        }.dispose(in: disposeBag)
        
        //TODO migration-check
        //Before migration code
        /*
        [
            emailTextField.bnd_userInteractionEnabled,
            passwordTextField.bnd_userInteractionEnabled,
            firstNameTextField.bnd_userInteractionEnabled,
            lastNameTextField.bnd_userInteractionEnabled,
            zipCodeTextField.bnd_userInteractionEnabled,
            referralCodeTextField.bnd_userInteractionEnabled,
            mobilePhoneTextField.bnd_userInteractionEnabled
            ].forEach {
                joinButton.bnd_userInteractionEnabled.bind(to: $0)
        }
 */
    }
    
    fileprivate func signUp() {
        joinButton.activityState.next(.busy)
        viewModel.signUpRequest.execute { [weak self] resolver in
            guard let self = self else {
                return
            }
            do {
                let user = try resolver().0
                self.authRouter.openHome(true)
                UserDefaults.standard.set(true, forKey: NSUserDefaultsDataKeys.NotFirstLaunch.rawValue)
                UserDefaults.standard.synchronize()
                DataProvider.sharedInstance.userWrapper = UserWrapper(user: user)
            } catch let error as BackendError {
                self.handleError(error)
            } catch {}
            self.joinButton.activityState.next(.idle)
        }
    }

    @IBAction func signIn(_ sender: UIButton) {
        if (navigationController?.viewControllers.first == self) {
            performSegueWithIdentifier(.SignIn)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = (textField as? TextFieldWithNext)?.nextTextField {
            nextTextField.becomeFirstResponder()
            return false
        }
        if textField == referralCodeTextField.textField {
            textField.resignFirstResponder()
            
            let bag = DisposeBag()
            let observer = referralCodeTextField.state.observeNext { [weak self] state in
                switch state {
                case .checked:
                    bag.dispose()
                    self?.signUp()
                case .invalid:
                    bag.dispose()
                default:()
                }
            }
            bag.add(disposable: observer)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let deleting = newText.count < textField.text?.count
        
        var stripppedNumber = newText.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: newText.startIndex ..< newText.endIndex)
        let digits = stripppedNumber.count
        
        if (textField == self.mobilePhoneTextField.textField) {
            if digits > 10 {
                
                //TODO migration-check
                
                //Before migration code
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
                //result = "(" + stripppedNumber.substring(to: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 3)) + ") " + stripppedNumber.substring(from: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 3))
                
                //Possible fix
                result = "(" + stripppedNumber.substring(to: 3) + ") " + stripppedNumber.substring(from: 3)
                
                
            } else {
                
                //TODO migration-check
                
                //Before migration code
                //result = "(" + stripppedNumber.substring(to: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 3)) + ") " + stripppedNumber.substring(with: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 3) ..< <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 6)) + "-" + stripppedNumber.substring(from: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 6))
                
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
                _ = self.textFieldShouldReturn(textField)
            }
            return false;
        } else if textField == emailTextField.textField {
            if string == " " {
                return false
            }
            if range.location == 0 && range.length == textField.text?.count {
                viewModel.email.value = string
            }
        } else if (textField == zipCodeTextField.textField) {
            if digits >= 5 {
                
                //TODO migration-check
                
                //Before migration code
                //stripppedNumber = stripppedNumber.substring(to: <#T##String.CharacterView corresponding to `startIndex`##String.CharacterView#>.index(startIndex, offsetBy: 5))
                
                //Possible fix
                stripppedNumber = stripppedNumber.substring(to: 5)
                
                zipCodeTextField.text = stripppedNumber
                _ = textFieldShouldReturn(textField)
                return false
            }
        }
        return true;
        
    }
}

extension SignUpViewController: KeyboardListenerProtocol {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //subscribeForKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //unsubscribe()
    }
    
    func getAboveKeyboardView() -> UIView? {
        return referralCodeTextField
    }
}

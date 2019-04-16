//
//  SignInViewController.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

final class SignInViewModel: ViewModel {
    let email: Observable<String?> = Observable(UserDefaults.standard.string(forKey: NSUserDefaultsDataKeys.LatestEmailAddress.rawValue))
    let password: Observable<String?> = Observable(nil)
    
    var isValid: Bool {
        if let emailVal = email.value,
            let passwordVal = password.value {
            if passwordVal.count >= 4 && emailVal.isEmail {
                return true
            }
        }
        return false
    }
    
    func storeLatestEmail() {
        if let email = self.email.value, email.isEmail {
            let ud = UserDefaults.standard
            ud.setValue(email, forKey: NSUserDefaultsDataKeys.LatestEmailAddress.rawValue)
            ud.synchronize()
        }
    }
    
    var loginRequest: Action<UserResolver> {
        return Action { [weak self] in
            Signal { [weak self] sink in
                if let emailVal = self?.email.value,
                    let passwordVal = self?.password.value {
                    _ = LemonAPI.login(email: emailVal, password: passwordVal).request().observeNext { (event: EventResolver<User>) in
                        do {
                            let user = try event()
                            if user.isAdmin {
                                save(user:user)
                                LemonAPI.userId = user.id
                                LemonAPI.userPassword = passwordVal
                                sink.completed(with: { return user })
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change `2.0` to the desired number of seconds.
                                    
                                    _ = LemonAPI.startSession(userId: user.id, email: emailVal, password: passwordVal)
                                        .request().observeNext { (tokenResolver: EventResolver<AccessToken>) in
                                            
                                            do {
                                                let token = try tokenResolver()
                                                saveToken(token: token)
                                                LemonAPI.accessToken = token
                                                self?.storeLatestEmail()
                                                
                                            } catch let error {
                                                sink.completed(with:  { throw error } )
                                            }
                                    }
                                }
                            } else {
                                let invalidUserError = InvalidUserError()
                                    sink.completed(with: {throw invalidUserError})
                            }
                        } catch let error {
                            sink.completed(with:  { throw error } )
                        }
                    }
                }
                return BlockDisposable {}
                //return nil
            }
        }
    }
}

let notificationNameToken = Notification.Name("TokenSaved")
func saveToken(token: AccessToken) {
    LemonAPI.accessToken = token
    
    DataProvider.sharedInstance.refreshAllData()
    NotificationCenter.default.post(name: notificationNameToken, object: nil)
}

struct InvalidUserError: ErrorWithDescriptionType {
    
    var title: String {
        return "Sorry"
    }
    
    var message: String {
        return "Wrong email or password"
    }
}

final class SignInViewController: UIViewController {
    
    @IBOutlet fileprivate weak var emailTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    
    var viewModel: SignInViewModel = SignInViewModel()
    var authRouter: AuthRouter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.authRouter = AuthRouter()
        // to handle keyboard shortcut replacement will "bind" model to textfield in delegae
        
        //TODO migration-check
        
        //Before migration code
        //emailTextField.bnd_text.value = viewModel.email.value
        
        //Possible fix
        emailTextField.text = viewModel.email.value
        
        emailTextField.bnd_text.bind(to: viewModel.email)
        self.viewModel.password.bidirectionalBind(to: passwordTextField.bnd_text)
    }
    
    @IBAction func signIn(_ sender: UIButton?) {
        
        if viewModel.isValid {
            showLoadingOverlay()
            viewModel.loginRequest.execute { [weak self] resolver in
                guard let self = self else {
                    hideLoadingOverlay()
                    return }
                
                do {
                    let user = try resolver()
                    UserDefaults.standard.set(true, forKey: NSUserDefaultsDataKeys.NotFirstLaunch.rawValue)
                    UserDefaults.standard.synchronize()
                    DataProvider.sharedInstance.userWrapper = UserWrapper(user: user)
                    self.authRouter.openHome(true)
                    hideLoadingOverlay()
                } catch let error as BackendError {
                    hideLoadingOverlay()
                    self.handleError(error)
                } catch let invalidUser as InvalidUserError {
                    hideLoadingOverlay()
                    self.handleError(invalidUser)
                }catch let error {
                    hideLoadingOverlay()
                }
                
            }
        } else {
            showAlert("Sorry", message: "Wrong email or password", positiveButton: "OK", cancelButton: nil)
        }
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        if (navigationController?.viewControllers.first == self) {
            performSegueWithIdentifier(.SignUp)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc  = segue.destination as? RestorePasswordViewController {
            vc.viewModel = RestorePasswordViewModel(email: viewModel.email.value)
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            textField.resignFirstResponder()
            signIn(nil)
        } else {
            passwordTextField.becomeFirstResponder()
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailTextField {
            if string == " " {
                return false
            }
            if range.location == 0 && range.length == textField.text?.count {
                viewModel.email.value = string
            }
        }
        return true
    }
}

extension SignInViewController: KeyboardListenerProtocol {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //subscribeForKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //unsubscribe()
    }
    
    func getAboveKeyboardView() -> UIView? {
        return passwordTextField
    }
}


//
//  RestorePasswordViewController.swift
//  lemonapp
//
//  Created by mac-190-mini on 12/31/15.
//  Copyright © 2015 11lemons. All rights reserved.
//

import UIKit
import Bond

final class RestorePasswordViewModel: ViewModel {
    
    let email = Observable<String?>(nil)
    
    init(email: String?) {
        self.email.value = email
    }
    
    var isValid: Bool {
        if let emailVal = email.value {
                if emailVal.isEmail {
                    return true
                }
        }
        return false
    }
    
    lazy var restorePasswordRequest: Action<() throws -> ()> = {
        Action { [weak self] in
            LemonAPI.restorePassword(email: self?.email.value ?? "").request()
        }
    }()
}

final class RestorePasswordViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    
    var viewModel: RestorePasswordViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    
    fileprivate func bindViewModel() {
        guard viewModel != nil && isViewLoaded else { return }
        
        // to handle keyboard shortcut replacement will "bind" model to textfield in delegae
        emailTextField.bnd_text.bind(to: viewModel!.email)
    }
    
    @IBAction func restorePassword(_ sender: UIButton?) {
        
        guard let viewModel = viewModel else { return }
        
        
        if viewModel.isValid {
            showLoadingOverlay()
            viewModel.restorePasswordRequest.execute { [weak self] in
                do {
                    try $0()
                    self?.navigationController?.showAlert("Restore Password",
                        message: "We sent an email to \(viewModel.email.value!) with a temporary password",
                        positiveButton: "OK",
                        positiveAction: { _ in
                            self?.navigationController?.popViewController(animated: true)
                    })

                } catch let error as BackendError {
                    self?.handleError(error)
                } catch let error {
                    print(error)
                }
                hideLoadingOverlay()
            }
        } else {
            showAlert("Sorry", message: "Wrong email address")
        }

    }
    
    @IBAction func signIn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension RestorePasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            textField.resignFirstResponder()
            restorePassword(nil)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        if range.location == 0 && range.length == textField.text?.count {
            viewModel?.email.value = string
        }
        return true
    }
}

extension RestorePasswordViewController: KeyboardListenerProtocol {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeForKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unsubscribe()
    }
    
    func getAboveKeyboardView() -> UIView? {
        return emailTextField
    }
}

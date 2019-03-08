//
//  ProfileViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit


final class ProfileViewModel: ViewModel {
    
    var userViewModel: UserViewModel
    
    let profileInfoViewModel: ProfileInfoViewModel
    let editMode: Observable<Bool>
    
    var uploadingPhoto: UIImage?
    
    fileprivate let userWrapper: UserWrapper
    
    init (userWrapper: UserWrapper, router: ProfileRouter) {
        self.userWrapper = userWrapper
        profileInfoViewModel = ProfileInfoViewModel(userWrapper: userWrapper, router: router)
        userViewModel = UserViewModel(userWrapper: userWrapper, editMode: profileInfoViewModel.editMode)
        editMode = profileInfoViewModel.editMode
    }
    
    var uploadPhoto: Action<() throws -> ()> {
        return Action { [weak self] in
            Signal { [weak self] sink in
                if let photo = self?.uploadingPhoto {
                    ImageCache.saveImage(photo, url: "profile_photo").observeNext {
                        if let fileURL = $0() {
                            _ = LemonAPI.uploadPhoto(photoFile: fileURL)
                                .request().observeNext { (resultResolver:EventResolver<String>) in
                                    do {
                                        let profilePhoto = try resultResolver()
                                        if let userWrapper = self?.userWrapper,
                                        let profilePhoto = NSURL(string: profilePhoto)!.lastPathComponent {
                                            ImageCache.saveImage(photo, url: profilePhoto).observeNext { _ in
                                                userWrapper.profilePhoto.value = profilePhoto
                                                userWrapper.saveChanges()
                                                sink.completed(with: {})
                                            }
                                        } else {
                                            sink.completed(with: {})
                                        }
                                    } catch let error {
                                        sink.completed(with:  { throw error } )
                                    }                                    
                            }
                        }
                    }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
}

final class ProfileViewController: UIViewController {
    
    fileprivate static let AS_TAKE_PHOTO_INDEX = 1
    fileprivate static let AS_PHOTO_LIBRARY_INDEX = 2
    
    @IBOutlet fileprivate weak var userView: UserView! {
        didSet {
            self.userView.delegate = self
        }
    }
    
    var viewModel: ProfileViewModel? {
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
        
        userView.viewModel = viewModel?.userViewModel       
        
        guard let profileNC = (childViewControllers.first as? UINavigationController) else { return }
        
        guard let profileInfoVC = (profileNC.viewControllers.first as? ProfileInfoViewController) else { return }
        
        profileInfoVC.viewModel = viewModel?.profileInfoViewModel
        viewModel?.editMode.observeNext { [weak self] in
            if $0 {
                self?.userView.nameTextField.isEnabled = true
                self?.userView.nameTextField.becomeFirstResponder()
            }
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension ProfileViewController: UserViewDelegate {
    
    func nameTextFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let emailTextField = ((self.childViewControllers.first as? UINavigationController)?.topViewController as? ProfileInfoViewController)?.emailTextField {
            emailTextField.becomeFirstResponder()
            return false
        }
        return true
    }
    
    func userViewDidTapImage(_ userView: UserView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            self?.showImagePicker(.camera)
        })
        alertController.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.showImagePicker(.photoLibrary)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        show(alertController, sender: self)
    }
    
    fileprivate func showImagePicker(_ sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.showDetailViewController(imagePicker, sender: self)
    }
    
}

extension ProfileViewController: KeyboardListenerProtocol {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //subscribeForKeyboard()
        
        //replacing navigation bar (hack)
        guard let profileNC = (childViewControllers.first as? UINavigationController) else { return }

        //let navigationBar = profileNC.navigationBar
        //navigationBar.removeFromSuperview()
//        navigationBar.frame.origin.x = 4
//        navigationBar.frame.origin.y = 20
//        navigationBar.frame.size.width = self.view.frame.width
//        navigationBar .autoresizingMask = [.flexibleWidth]
        //self.view.addSubview(navigationBar)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //unsubscribe()
        DataProvider.sharedInstance.userWrapper?.refresh()
    }
    
    func getAboveKeyboardView() -> UIView? {
        if self.userView.nameTextField.isFirstResponder {
            return self.userView.nameTextField
        }
        return ((self.childViewControllers.first as? UINavigationController)?.topViewController as? KeyboardListenerProtocol)?.getAboveKeyboardView()
    }
    
    var holdNavigationBar: Bool {
        return ((self.childViewControllers.first as? UINavigationController)?.topViewController as? KeyboardListenerProtocol)?.holdNavigationBar ?? false
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        if let photo = info[UIImagePickerControllerEditedImage] as? UIImage {
            showLoadingOverlay()
            viewModel?.uploadingPhoto = photo
            viewModel?.uploadPhoto.execute { [weak self] resolver in
                do {
                    try resolver()
                    self?.userView.viewModel = self?.viewModel?.userViewModel
                    AlertView().showInView(self?.navigationController?.parent?.view)
                } catch let error as BackendError {
                    self?.handleError(error)
                } catch let error {
                    print(error)
                }
                hideLoadingOverlay()
            }
        }
    }
}

//
//  DeliveryViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Braintree
import PassKit
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



final class DeliveryViewController : UIViewController {
    
    @IBOutlet fileprivate weak var deliveryLabel: UILabel!
    @IBOutlet fileprivate weak var notesHintLabel: UILabel!
    @IBOutlet fileprivate weak var notesTextView: UITextView!
    @IBOutlet fileprivate weak var cameraButton: UIButton!
    @IBOutlet fileprivate weak var completeButton: UIButton!
    @IBOutlet var completeOrderBtnHeight: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var deliveryOptionPicker: DeliveryOptionPicker!
    
    @IBOutlet var promocodeTextField: UITextField!
    @IBOutlet var promocodeView: PromocodeView!
    
    @IBOutlet var addressField: RequiredFieldView!
    @IBOutlet var paymentField: RequiredFieldView!
    @IBOutlet var walletView: WalletView!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var orderPlacingActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet fileprivate weak var orderDetailsButton: UIBarButtonItem!
    
    @IBOutlet fileprivate weak var walletViewBottomSeparator: UIView!
    @IBOutlet var walletContainerStackView: UIStackView!
    @IBOutlet fileprivate weak var nextPickupView: NextPickupView!
    @IBOutlet fileprivate weak var nextPickupViewContainer: UIView!
    @IBOutlet fileprivate weak var nextPickupViewSeparator: UIView!
    
    fileprivate var timer: Timer?
    
    
    var router: NewOrderRouter?
    
    fileprivate var braintreeClient: BTAPIClient?
    
    var viewModel: DeliveryViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: completeOrderBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: completeButton)

        setLemonBackground()
        
        if let token = DataProvider.sharedInstance.paymentToken {
            braintreeClient = BTAPIClient(authorization: token)
        }
        
        if let viewModel = viewModel {
            bindViewModel(viewModel)
            promocodeView.isUserInteractionEnabled = true
            addressField.isUserInteractionEnabled = true
            paymentField.isUserInteractionEnabled = true
        }
        
        notesTextView.textContainerInset = UIEdgeInsetsMake(15, 10, 15, 10);
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //subscribeForKeyboard()
        viewModel?.refresh()
        (self.navigationController as? YellowNavigationController)?.barStyle.value = .yellow
        
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.forsePickupETAUpdate), userInfo: nil, repeats: true)
        
        nextPickupView.startAnimation()
    }
    
    @objc fileprivate func forsePickupETAUpdate() {
        viewModel?.pickupETA.next((viewModel?.pickupETA.value)!)
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        timer?.invalidate()
//        timer = nil
//
//        nextPickupView.stopAnimation()
//    }

    
    func bindViewModel(_ viewModel: DeliveryViewModel) {
        viewModel.timeConstraint.map { deliveryTextForTimeConstraint($0)}.bind(to: deliveryLabel!.bnd_attributedText)
        
        viewModel.selectedDeliveryOption.bidirectionalBind(to: deliveryOptionPicker.selectedOption)
        
        viewModel.shouldHideNotesHint.map { [weak self] hide in
            if hide {
                return hide
            } else {
                let isTextViewInEditMode = self?.notesTextView.isFirstResponder
                return isTextViewInEditMode == true
            }
            }.bind(to: notesHintLabel.bnd_hidden)
        viewModel.notes.bind(to: notesTextView.bnd_text)
        notesTextView.bnd_text.bind(to: viewModel.notes)
        
        viewModel.walletViewModel.observeNext { [weak self] in self?.walletView.viewModel = $0 }
        
        
        viewModel.paymentOption.observeNext { [weak self] option in
            if let option = option {
                switch option {
                case Option.chose(let card):
                    if let card  = card as? PaymentCard {
                        //self?.paymentField.valueLabel.bnd_text.next(card.type.rawValue)
                        self?.paymentField.valueLabelText.next(card.type.rawValue)
                        //self?.paymentField.specialImageView?.bnd_image.next(card.type.image)
                        self?.paymentField.specialImage.next(card.type.image)
                        self?.paymentField.showSuccess()
                    } else if let card = card as? ApplePayCard {
                        //self?.paymentField.valueLabel.bnd_text.next("Apple Pay")
                        self?.paymentField.valueLabelText.next("Apple Pay")
                        //self?.paymentField.specialImageView?.bnd_image.next(card.image)
                        self?.paymentField.specialImage.next(card.image)
                        self?.paymentField.showSuccess()
                    }
                default: ()
                }
            }
        }
        
        paymentField.selectButton.bnd_tap.observeNext { [weak self] in
            self?.showPickupPaymentAlert()
        }
        
        
        viewModel.address.observeNext { [weak self] address in
            let text = address?.nickname ?? ""
            //self?.addressField.valueLabel.bnd_text.next(text)
            self?.addressField.valueLabelText.next(text)
            if text.count > 0 {
                self?.addressField.showSuccess()
            }
        }
        addressField.selectButton.bnd_tap.observeNext { [weak self] in
            if let userWrapper = DataProvider.sharedInstance.userWrapper {
                //swift native bug!!! without map() getting crash
                let addressList: [OptionItemProtocol] = userWrapper.activeAddresses.map { $0 }
                let addressPicker = OptionPicker(optionItemList: addressList, optionsType: .addresses) { [weak self] selectedAddress in
                    if let address = selectedAddress {
                        switch address {
                        case .new:
                            (self?.navigationController as? YellowNavigationController)?.barStyle.value = .transparent
                            self?.performSegueWithIdentifier(.NewAddress, sender: viewModel.newAddressViewModel)
                        case .chose(let address):
                            if let realAddress = address as? Address {
                                self?.viewModel?.address.value = realAddress
                            }
                        }
                    }
                }
                self?.present(addressPicker, animated: true, completion: nil)
            }
        }
        
        completeButton.bnd_tap.observeNext { [weak self] in
                var allFieldsAreFilled = true
                
                if self?.viewModel?.address.value == nil {
                    self?.addressField.showError()
                    allFieldsAreFilled = false
                    if let addressField = self?.addressField {
                        self?.scrollView.scrollRectToVisible(addressField.frame, animated: true)
                    }
                }
                
                if let option = self?.viewModel?.paymentOption.value {
                    switch option {
                    case .chose:
                        break
                    default:
                        allFieldsAreFilled = false
                        self?.paymentField.showError()
                        if let paymentField = self?.paymentField {
                            self?.scrollView.scrollRectToVisible(paymentField.frame, animated: true)
                        }
                    }
                } else {
                    allFieldsAreFilled = false
                    self?.paymentField.showError()
                    if let paymentField = self?.paymentField {
                        self?.scrollView.scrollRectToVisible(paymentField.frame, animated: true)
                    }
                }
                
                if !allFieldsAreFilled {
                    return
                }
                
                self?.viewModel?.checkAddressRequest.execute { (resolver: EventResolver<[LocationData]>) in
                    do {
                        let result = try resolver()
                        if let location = result.first, location.allowReg {
                            if let option = self?.viewModel?.paymentOption.value {
                                switch option {
                                case .chose(let card):
                                    if card is ApplePayCard {
                                        self?.payWithApplePay()
                                        return
                                    }
                                default:
                                    break
                                }
                            } else {
                                self?.showPickupPaymentAlert()
                                return
                            }
                            self?.complete()
                        } else {
                            self?.handleError(LemonError.unavailableLocation)
                        }
                    } catch let error as BackendError {
                        print(error.message)
                        self?.handleError(error)
                    } catch {}
                }
            
        }

        cameraButton.bnd_tap.observeNext { [weak self] in self?.showCameraOptions() }
        viewModel.photos.observeNext { [weak self] _ in
            if viewModel.photos.array.count > 0 {
                self?.cameraButton.setBackgroundImage(UIImage(assetIdentifier: .NotesCameraRed), for: UIControlState())
                self?.cameraButton.setTitle("\(viewModel.photos.array.count)")
            } else {
                self?.cameraButton.setBackgroundImage(UIImage(assetIdentifier: .NotesCameraNormal), for: UIControlState())
                self?.cameraButton.setTitle("")
            }
        }
        
        promocodeTextField.bnd_text.bidirectionalBind(to: viewModel.promocode)
        promocodeTextField.bnd_controlEvent(UIControlEvents.editingDidEnd).observeNext { [weak self] _ in
            self?.promocodeView.activityIndicator.isHidden = false
            self?.viewModel?.validatePromocode.execute { [weak self] result in
                do {
                    self?.promocodeView.activityIndicator.isHidden = true
                    self?.promocodeView.promocodeIsValid = try result()
                } catch {
                    self?.promocodeView.promocodeIsValid = false
                }
            }
        }
        self.title = viewModel.editMode ? "Edit Order" : "New Order"
        
        viewModel.completeButtonTitleChanged.bind(to: completeButton.bnd_title)
        //completeButton.bnd_title.next(viewModel.editMode ? "Update Order" : "Complete Order")
        viewModel.completeButtonTitleChanged.next(viewModel.editMode ? "Update Order" : "Complete Order")
        
        DataProvider.sharedInstance.pickupETA.bind(to: viewModel.pickupETA)
        
        viewModel.pickupETA.observeNext { [weak self] (value) in
            let date = Date().pickupShift(value)
            self?.nextPickupView.setTitle(date.timeHM(), subtitle: date.amPm())
        }
        
        viewModel.userWalletBalance.observeNext { [weak self](amount) in
            var walletAmountHidden = true
            if let amount = amount {
                walletAmountHidden = !(amount > 0)
            }
            self?.walletView.isHidden = walletAmountHidden
            self?.walletViewBottomSeparator.isHidden = !walletAmountHidden
            self?.nextPickupViewContainer.backgroundColor = walletAmountHidden ? UIColor.lemonColor() : UIColor.clear
            self?.nextPickupViewContainer.isHidden = !walletAmountHidden
        }
        
        self.orderDetailsButton.isEnabled = false
        self.orderDetailsButton.tintColor = UIColor.clear
        self.orderDetailsButton.target = self
        self.orderDetailsButton.action = #selector(DeliveryViewController.didOrderDetailsButtonClicked(_:))
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewModel = sender as? CommonContainerViewModel, let viewController = segue.destination as? CommonContainerViewController {
            viewController.viewModel = viewModel
        }
    }
    
    
    fileprivate func showPickupPaymentAlert() {
        if let userWrapper = DataProvider.sharedInstance.userWrapper {
            //swift native bug!!! without map() getting crash
            var cardList: [OptionItemProtocol] = userWrapper.activePaymentCards.map { $0 }
            if let applePay = userWrapper.applePayCard {
                cardList.append(applePay)
            }
            
            let paymentPicker = OptionPicker(optionItemList: cardList, optionsType: .paymentCards) { selectedPaymentOption in
                if let selectedOption = selectedPaymentOption {
                    switch selectedOption {
                    case Option.chose:
                        self.viewModel?.paymentOption.value = selectedOption
                    case Option.new:
                        (self.navigationController as? YellowNavigationController)?.barStyle.value = .transparent
                        self.performSegueWithIdentifier(.NewPayment, sender: self.viewModel?.newPaymentViewModel)
                    }
                }
            }
            self.present(paymentPicker, animated: true, completion: nil)
        }
    }
    
    
    fileprivate func complete() {
        showLoadingOverlay()
        
        orderPlacingActivityIndicator.isHidden = false
        completeButton.isUserInteractionEnabled = false
        self.viewModel?.sendOrder.execute { [weak self] result in
            do {
                self?.orderPlacingActivityIndicator.isHidden = true
                self?.completeButton.isUserInteractionEnabled = true
                if let order = try result() {
                    DataProvider.sharedInstance.userOrders.insert(order, at: 0)
                }
                self?.navigationController?.popToRootViewController(animated: true)
                AlertView().showInView(UIApplication.shared.delegate?.window??.rootViewController?.view) { [weak self] in
                    self?.router?.suggestNotifications()
                }
            } catch let error as BackendError {
                print(error.message)
                self?.handleError(error)
            } catch {}
            hideLoadingOverlay()
        }
    }
    
    
    fileprivate func payWithApplePay() {
        if let defaultApplePay = viewModel?.defaultApplePay {
            viewModel?.applePayToken.next(defaultApplePay)
            self.complete()
        } else {
            let viewController = PKPaymentAuthorizationViewController(paymentRequest: PKPaymentRequest.lemonPaymentRequest)
            viewController?.delegate = self
            present(viewController!, animated: true, completion: nil)
        }
    }
    
    
    fileprivate func showCameraOptions() {
        let imageSize: CGFloat = 100
        let spacerSize: CGFloat = 20

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let margin: CGFloat = 8.0
        let rect = CGRect(x: margin, y: margin, width: alertController.view.bounds.size.width - margin * 5, height: 120.0)
        
        let scrollView = UIScrollView(frame: rect)
        scrollView.isUserInteractionEnabled = true
        scrollView.isExclusiveTouch = true
        scrollView.canCancelContentTouches = true
        scrollView.delaysContentTouches = true
        
        viewModel?.photos.observeNext { [weak self] _ in
            let title: String? = (self?.viewModel?.photos.count > 0) ? "\n\n\n\n\n" : ""
            alertController.title = title
            scrollView.subviews.forEach({ $0.removeFromSuperview() })
            var scrollViewContentSize: CGFloat = 0
            var xPosition: CGFloat = 0
            
            if self?.viewModel?.photos.array.count > 0 {
                for imageIndex in 0..<(self?.viewModel?.photos.count ?? 0) {
                    let containerView = UIView()
                    containerView.frame.size.width = imageSize + 20
                    containerView.frame.size.height = imageSize + 20
                    containerView.frame.origin.x = xPosition
                    containerView.isUserInteractionEnabled = true
                    
                    let photoView = UIImageView()
                    photoView.contentMode = UIViewContentMode.scaleAspectFit
                    photoView.frame.size.width = imageSize
                    photoView.frame.size.height = imageSize
                    photoView.frame.origin.y = 10
                    photoView.image = self?.viewModel?.photos.array[imageIndex].photo
                    photoView.isUserInteractionEnabled = true
                    containerView.addSubview(photoView)
                    
                    let removeBtn = UIButton(type: .custom)
                    let photoViewRect = self?.calculateRectOfImageInImageView(photoView)
                    removeBtn.frame = CGRect(x: (photoViewRect?.width ?? photoView.frame.width) - 10, y: (photoViewRect?.origin.y ?? 0) - 10, width: 20, height: 20)
                    removeBtn.cornerRadius = removeBtn.frame.width / 2
                    removeBtn.setImage(UIImage(named: "btn_delete"), for: UIControlState())
                    removeBtn.tag = imageIndex
                    removeBtn.addTarget(self, action: #selector(DeliveryViewController.removeImage(_:)), for: .touchDown)
                    containerView.addSubview(removeBtn)
                    
                    xPosition += imageSize + spacerSize
                    scrollViewContentSize += imageSize + spacerSize
                    scrollView.contentSize = CGSize(width: scrollViewContentSize, height: imageSize)
                    
                    scrollView.addSubview(containerView)
                }
            }
            
            scrollView.frame = CGRect(origin: scrollView.frame.origin, size: CGSize(width: scrollView.frame.size.width, height: self?.viewModel?.photos.array.count > 0 ? 120 : 0))
        }
        
        alertController.view.addSubview(scrollView)
        
        alertController.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.showImagePicker(.photoLibrary)
            })
        alertController.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            self?.showImagePicker(.camera)
            })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func calculateRectOfImageInImageView(_ imageView: UIImageView) -> CGRect {
        let imageViewSize = imageView.frame.size
        let imgSize = imageView.image?.size
        
        guard let imageSize = imgSize, imgSize != nil else {
            return CGRect.zero
        }
        
        let scaleWidth = imageViewSize.width / imageSize.width
        let scaleHeight = imageViewSize.height / imageSize.height
        let aspect = fmin(scaleWidth, scaleHeight)
        
        var imageRect = CGRect(x: 0, y: 0, width: imageSize.width * aspect, height: imageSize.height * aspect)
        // Center image
        imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
        imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2
        
        // Add imageView offset
        imageRect.origin.x += imageView.frame.origin.x
        imageRect.origin.y += imageView.frame.origin.y
        
        return imageRect
    }
    
    fileprivate func showImagePicker(_ sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.showDetailViewController(imagePicker, sender: self)
    }
    
    @objc func removeImage(_ sender: UIButton) {
        if let pic = self.viewModel?.photos.array[sender.tag], pic.orderPicId > 0 {
            _ = LemonAPI.deleteOrderImage(orderId: pic.orderId, picId: pic.orderPicId).request().observeNext { [weak self] (resolver: EventResolver<String?>) in
                self?.viewModel?.photos.remove(at: sender.tag)
            }
        } else {
            self.viewModel?.photos.remove(at: sender.tag)
        }
    }
    
    @objc func didOrderDetailsButtonClicked(_ sender: AnyObject?) {
        if let viewModel = self.viewModel {
            router?.showOrderServicesFlow(self, order: viewModel.order)
        }
    }
}


extension DeliveryViewController: PKPaymentAuthorizationViewControllerDelegate {

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        if let braintreeClient = self.braintreeClient {
            let client = BTApplePayClient(apiClient: braintreeClient)
            client.tokenizeApplePay(payment) { [weak self] nounce, error in
                if let error = error {
                    print("error apple pay: \(error.localizedDescription)")
                    completion(.failure)
                } else {
                    print("succeseed apple pay")
                    self?.viewModel?.applePayToken.value = nounce?.nonce ?? nil
                    completion(.success)
                }
            }
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        self.dismiss(animated: true) { [weak self] in
            if self?.viewModel?.applePayToken.value != nil {
                self?.complete()
            }
        }
    }
}


extension DeliveryViewController: UITextViewDelegate {
        
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.rangeOfCharacter(from: CharacterSet.newlines) == nil {
            return true
        }
        textView.resignFirstResponder()
        return false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        notesHintLabel.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        notesHintLabel.isHidden = notesTextView.text.count > 0
    }
}


extension DeliveryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}


extension DeliveryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        if let photo = info[UIImagePickerControllerEditedImage] as? UIImage {
            viewModel?.photos.append(OrderPhoto(orderId: 0, orderPicId: 0, photo: photo))
        }
    }
}


extension DeliveryViewController: KeyboardListenerProtocol {
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //unsubscribe()
        
        timer?.invalidate()
        timer = nil
        
        nextPickupView.stopAnimation()
    }
    
    //var holdNavigationBar: Bool { return true }
    
    func getAboveKeyboardView() -> UIView? {
        return promocodeTextField
    }
}


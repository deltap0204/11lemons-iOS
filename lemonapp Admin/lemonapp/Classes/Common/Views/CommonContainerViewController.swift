//
//  CommonContainerViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond

final class CommonContainerViewModel: ViewModel {
 
    let screenIndetifier: StoryboardScreenIdentifier
    let userViewModel: UserViewModel
    fileprivate let backButtonTitle: String

    var childViewModel: ViewModel? {
        switch self.screenIndetifier {
        case .AddressScreen:
            return AddressDetailsViewModel(userWrapper: userWrapper, backButtonTitle: backButtonTitle)
        case .PaymentCardScreen:
            return PaymentCardDetailsViewModel(userWrapper: userWrapper, backButtonTitle: backButtonTitle)
            
        case .SettingsScreen:
            return SettingsViewModel(userWrapper: userWrapper, settingsRouter: router as? SettingsRouter)
//        case .SettingsScreen:
//            return SettingsViewModel(userWrapper: userWrapper, settingsRouter: router as? SettingsRouter)
        default:
            return nil
        }
    }
    
    let result: Observable<AnyObject?> = Observable(nil)
    
    var title: String? {
        switch self.screenIndetifier {
        case .AddressScreen:
            return "New Address"
        case .PaymentCardScreen:
            return "Add Card"
        default:
            return nil
        }
    }
    
    fileprivate let userWrapper: UserWrapper
    fileprivate let router: AnyObject?
    
    init(userWrapper: UserWrapper, screenIndetifier: StoryboardScreenIdentifier, router: AnyObject? = nil, backButtonTitle: String = "") {
        self.router = router
        self.userWrapper = userWrapper
        self.backButtonTitle = backButtonTitle
        self.userViewModel = UserViewModel(userWrapper: userWrapper)
        self.screenIndetifier = screenIndetifier
    }
    
    func bindViewModelToViewController(_ viewController: UIViewController) {
        switch self.screenIndetifier {
        case .AddressScreen:
            if let addressVC = viewController as? AddressDetailsViewController {
                addressVC.viewModel = childViewModel as? AddressDetailsViewModel
                addressVC.onResultHandler = { [weak self] result in
                    self?.result.value = result
                }
            }
        case .PaymentCardScreen:
            if let paymentCardVC = viewController as? PaymentCardDetailsViewController {
                paymentCardVC.viewModel = childViewModel as? PaymentCardDetailsViewModel
                paymentCardVC.onResultHandler = { [weak self] result in
                    self?.result.value = result
                }
            }
        case .SettingsScreen:
            if let settingsVC = (viewController as? UINavigationController)?.viewControllers.first as? SettingsViewController {
                settingsVC.viewModel = childViewModel as? SettingsViewModel
            }
        default:
            break
        }
    }
}

final class CommonContainerViewController: UIViewController {
    
    
    @IBOutlet fileprivate weak var container: UIView!
    @IBOutlet fileprivate weak var userView: UserView!
    @IBOutlet var userViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var backgroundViewTopConstraint: NSLayoutConstraint!
    
    var viewModel: CommonContainerViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: userViewTopConstraint, baseValue: userViewTopConstraint.constant)
        bindViewModel()
    }    
    
    fileprivate func bindViewModel() {
        guard viewModel != nil && isViewLoaded else { return }
        if let viewModel = viewModel {
        
            self.title = viewModel.title
            self.userView.viewModel = viewModel.userViewModel
        
            if let vc = self.storyboard?.instantiateViewControllerWithIdentifier(viewModel.screenIndetifier) {
                self.childViewControllers.forEach {
                    $0.willMove(toParentViewController: nil)
                    $0.view.removeFromSuperview()
                    $0.removeFromParentViewController()
                }
                self.addChildViewController(vc)
                vc.view.frame = self.container.bounds
                vc.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                self.container.addSubview(vc.view)
                vc.didMove(toParentViewController: self)
                self.navigationItem.leftBarButtonItems = vc.navigationItem.leftBarButtonItems

                viewModel.bindViewModelToViewController(vc)
            }
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension CommonContainerViewController: KeyboardListenerProtocol {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //subscribeForKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //unsubscribe()
    }
    
    //var holdNavigationBar: Bool { return viewModel?.screenIndetifier == .PaymentCardScreen }
    
    func getAboveKeyboardView() -> UIView? {
        if let view = (self.childViewControllers.first as? KeyboardListenerProtocol)?.getAboveKeyboardView() {
            return view
        } else {
            return ((self.childViewControllers.first as? UINavigationController)?.topViewController as? KeyboardListenerProtocol)?.getAboveKeyboardView()
        }
    }
}

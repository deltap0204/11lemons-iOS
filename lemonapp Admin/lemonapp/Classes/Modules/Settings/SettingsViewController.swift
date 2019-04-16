//
//  SettingsViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond
import DrawerController
import SnapKit
import ReactiveKit


final class SettingsViewController: UIViewController {
    
    @IBOutlet fileprivate weak var cloudClosetSwitch: UISwitch!
    @IBOutlet fileprivate weak var pushButton: UIButton!
    @IBOutlet fileprivate weak var emailButton: UIButton!
    @IBOutlet fileprivate weak var messageButton: UIButton!
    @IBOutlet var circularButtons: [UIButton]!
    @IBOutlet var cloudClosetIconView: UIImageView!
    
    @IBOutlet var doneBtn: HighlightedButton!
    @IBOutlet var doneBtnHeight: NSLayoutConstraint!
    
    var viewModel: SettingsViewModel? {
        didSet {
            if let viewModel = viewModel {
                bindViewModel(viewModel)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: doneBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: doneBtn)
        
        circularButtons.forEach { $0.centerImageAndTitle() }
        
        if let viewModel = viewModel {
            bindViewModel(viewModel)
        }
        
        cloudClosetIconView.tintColor = UIColor.white
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.alpha = 1
        viewModel?.refresh()
    }
    
    
    @IBAction func save(_ sender: AnyObject?) {
        if let viewModel = viewModel {
            viewModel.saveRequest.execute { [weak self] resolver in
                do {
                    try resolver()
                } catch let error as BackendError {
                    self?.handleError(error)
                } catch let error {
                    print(error)
                }
            }
            viewModel.goToOrders()
        }
    }

    
    func bindViewModel(_ viewModel: SettingsViewModel) {
        guard isViewLoaded else { return }
        
        viewModel.cloudClosetEnabled.bidirectionalBind(to: cloudClosetSwitch.bnd_on)

        viewModel.mailSelected.bind(to: emailButton.bnd_selected)
        viewModel.mailEnabled.bidirectionalBind(to: viewModel.mailSelected)
        
        viewModel.pushSelected.bind(to: pushButton.bnd_selected)
        viewModel.pushEnabled.bidirectionalBind(to: viewModel.pushSelected)
        
        viewModel.messageSelected.bind(to: messageButton.bnd_selected)
        viewModel.messageEnabled.bidirectionalBind(to: viewModel.messageSelected)

        
        emailButton.bnd_tap.observeNext { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.emailButton.isSelected = !strongSelf.emailButton.isSelected
            viewModel.mailSelected.next(strongSelf.emailButton.isSelected)
        }
        pushButton.bnd_tap.observeNext { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.pushButton.isSelected = !strongSelf.pushButton.isSelected
            viewModel.pushSelected.next(strongSelf.pushButton.isSelected)
        }
        messageButton.bnd_tap.observeNext { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.messageButton.isSelected = !strongSelf.messageButton.isSelected
            viewModel.messageSelected.next(strongSelf.messageButton.isSelected)
        }
    }
    
    
    
    @IBAction func showMenu() {
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }
}

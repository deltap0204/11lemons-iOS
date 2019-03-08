//
//  ProductAdminCell.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/4/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import UIKit
import Bond
import MGSwipeTableCell

final class ProductAdminCell: MGSwipeTableCell {
    
    static let Identifier = "ProductAdminCell"
    
    @IBOutlet fileprivate weak var viewShadows: UIView!
    @IBOutlet fileprivate weak var switchVisibility: UISwitch!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var detailsLabel: UILabel!
    @IBOutlet fileprivate weak var customImageView: UIImageView!
    @IBOutlet fileprivate weak var customAccessoryView: UIView!
    
    let editButton: UIButton
    
    var isFirstTime = true
    var viewModel: ProductAdminCellViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        editButton = Bundle.main.loadNibNamed("EditButton", owner: nil, options: nil)!.first! as! UIButton
        super.init(coder: aDecoder)
    }
    
    
    fileprivate func bindViewModel() {
        guard let viewModel = self.viewModel else { return }
        self.selectionStyle = .none
        self.titleLabel.text = viewModel.title
        self.detailsLabel.text = viewModel.details
        self.customImageView.image = viewModel.image
        self.customAccessoryView.isHidden = viewModel.isAccessoryViewHidden
        switchVisibility.isOn = viewModel.isActive.value
        switchVisibility.alpha = 0
        switchVisibility.isHidden = false
        isFirstTime = true
        self.viewShadows.isHidden = true
        
        viewModel.isEditionMode.observeNext { [weak self] isEditionMode in
            self?.switchVisibility.isOn = self?.viewModel!.isActive.value ?? true
            if isEditionMode {
                self?.animationEditionModeOn()
            } else {
                self?.animationEditionModeOff()
            }
        }
        let holdGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ProductAdminCell.showHoldAndEditEvent(_:)));
        holdGestureRecognizer.minimumPressDuration = 1.00;
        contentView.addGestureRecognizer(holdGestureRecognizer);
        
        rightButtons = [editButton]
    }
    
    @objc func showHoldAndEditEvent(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            viewModel?.editService()
        }
    }
    
    @IBAction func onSwitchChanged(_ sender: UISwitch) {
        viewModel?.isActive.value = sender.isOn
    }
    
    fileprivate func animationEditionModeOn() {
        if isFirstTime {
           isFirstTime = false
            self.customAccessoryView.alpha = 0
            self.contentView.alpha = 1
            self.switchVisibility.alpha = 1
        } else {
            UIView.animate(withDuration: 0.6,
               animations: {
                self.customAccessoryView.alpha = 0
                self.contentView.alpha = 1
                self.switchVisibility.alpha = 1
            })
        }
        
    }
    
    fileprivate func animationEditionModeOff() {
        if isFirstTime {
            isFirstTime = false
            self.switchVisibility.alpha = 0
            self.customAccessoryView.alpha = viewModel!.isAccessoryViewHidden ? 0 : 1
            self.contentView.alpha = viewModel!.isActive.value ? 1 : 0.25
        } else {
            UIView.animate(withDuration: 0.6,
               animations: {
                guard let vm = self.viewModel else { return }
                self.switchVisibility.alpha = 0
                self.customAccessoryView.alpha = vm.isAccessoryViewHidden ? 0 : 1
                self.contentView.alpha = vm.isActive.value ? 1 : 0.25
            })
        }
    }
}

//
//  DepartmentSelectionCell.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/4/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import UIKit
import Bond

final class DepartmentSelectionCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var imgLogo: UIImageView!
    @IBOutlet fileprivate weak var lblTitle: UILabel!
    @IBOutlet fileprivate weak var imgSelectStatus: UIImageView!
    @IBOutlet fileprivate weak var lblDescription: UILabel!
    @IBOutlet fileprivate weak var viewTouchSection: UIView!
    
    @IBOutlet fileprivate weak var lblNumber: UILabel!
    static let Identifier = "DepartmentSelectionCell"

    var viewModel: DepartmentSelectionCellModel? {
        didSet {
            bindViewModel()
        }
    }
    
    fileprivate func bindViewModel() {
        guard let viewModel = self.viewModel else { return }
        self.selectionStyle = .none
        
        self.lblTitle.text = viewModel.title
        self.lblDescription.text = viewModel.details
        self.imgLogo.image = viewModel.image
        self.contentView.alpha = viewModel.isActive ? 1.0 : 0.25
        viewModel.numberOfServicesSelected.map{ number in
            if number == 0 || number == viewModel.department.typesOfService!.count {
                return true
            }
            return false
        }.bind(to: lblNumber.bnd_hidden)
        
        viewModel.numberOfServicesSelected.map{ "\($0)"}.bind(to: lblNumber.bnd_text)
        
        viewModel.selectStatusImage.bind(to: imgSelectStatus.bnd_image)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DepartmentSelectionCell.selectAction(_:)));
        
        viewTouchSection.addGestureRecognizer(gestureRecognizer);
    }
    
    @objc func selectAction(_ sender: UITapGestureRecognizer) {
        guard let viewModel = self.viewModel else { return }
            viewModel.changeSelection()
    }
}

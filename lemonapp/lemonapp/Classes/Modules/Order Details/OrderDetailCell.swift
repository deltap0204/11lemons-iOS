//
//  OrderDetailCell.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit


class OrderDetailCell: UITableViewCell {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var infoLabel: UILabel!
    @IBOutlet fileprivate weak var infoTitleLabel: UILabel!
    @IBOutlet fileprivate weak var accessoryButton: UIButton!
    
    static let Id = "Cell"
    
    var viewModel: OrderDetailViewModel? {
        didSet {
            titleLabel.text = viewModel?.title
            infoLabel.text = viewModel?.info
            infoTitleLabel.text = viewModel?.infoTitle
            if let showsAccessory = viewModel?.showsAccessory {
                accessoryButton?.isHidden = !showsAccessory
            } else {
                accessoryButton?.isHidden = false
            }
        }
    }
}

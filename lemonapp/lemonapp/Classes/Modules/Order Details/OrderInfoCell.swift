//
//  OrderInfoCell.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit


class OrderInfoCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var infoLabel: UILabel!
    @IBOutlet fileprivate weak var infoTitleLabel: UILabel!
    
    static let Id = "InfoCell"
    
    var viewModel: OrderDetailViewModel? {
        didSet {
            infoLabel.text = viewModel?.info
            infoTitleLabel.text = viewModel?.infoTitle
        }
    }
}

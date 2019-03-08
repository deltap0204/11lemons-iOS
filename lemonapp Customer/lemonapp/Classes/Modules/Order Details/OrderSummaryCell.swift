//
//  OrderSummaryCell.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit


final class OrderSummaryCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var infoLabel: UILabel!
    @IBOutlet fileprivate weak var infoTitleLabel: UILabel!
    @IBOutlet fileprivate weak var totalLabel: UILabel!
    
    static let Id = "SummaryCell"
    
    var viewModel: OrderSummaryViewModel? {
        didSet {
            infoLabel.text = viewModel?.info
            infoTitleLabel.text = viewModel?.infoTitle
            totalLabel.text = viewModel?.total
        }
    }
}

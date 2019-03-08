//
//  SupportCell.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit


class SupportCell: UITableViewCell {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var valueLabel: UILabel!
    @IBOutlet fileprivate weak var accessoryImageView: UIImageView!

    var viewModel: SupportCellViewModel? {
        didSet {
            if let viewModel = viewModel {
                titleLabel.text = viewModel.title
                valueLabel.text = viewModel.value
                valueLabel.isHidden = viewModel.valueHidden
                accessoryImageView.isHidden = viewModel.accessoryHidden
            }
        }
    }
}

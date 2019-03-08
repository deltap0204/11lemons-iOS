//
//  QuestionCell.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit


class QuestionCell: UITableViewCell {

    @IBOutlet fileprivate weak var questionLabel: UILabel!
    
    static let CellId = "QuestionCell"
    
    var viewModel: FaqCellViewModel? {
        didSet {
            questionLabel.text = viewModel?.question
        }
    }
}

//
//  AnswerCell.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit


class AnswerCell: UITableViewCell {

    @IBOutlet fileprivate weak var questionLabel: UILabel!
    @IBOutlet fileprivate weak var answerLabel: UILabel!
    
    static let CellId = "AnswerCell"
    
    var viewModel: FaqCellViewModel? {
        didSet {
            questionLabel.text = viewModel?.question
            answerLabel.text = viewModel?.answer
        }
    }
}

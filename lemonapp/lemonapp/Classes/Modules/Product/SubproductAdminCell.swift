//
//  SubproductAdminCell.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/31/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import MGSwipeTableCell

final class SubproductAdminCell: MGSwipeTableCell {
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    @IBOutlet fileprivate weak var viewShadows: UIView!
    
    let deleteButton: UIButton
    let editButton: UIButton
    
    var viewModel: SubproductAdminCellViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        deleteButton = Bundle.main.loadNibNamed("DeleteButton", owner: nil, options: nil)!.first! as! UIButton
        editButton = Bundle.main.loadNibNamed("EditButton", owner: nil, options: nil)!.first! as! UIButton
        super.init(coder: aDecoder)
    }
    
    fileprivate func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        self.titleLabel.text = viewModel.title
        self.priceLabel.text = String(format:"$%.2f", viewModel.price)
        
        let isActiveValue:Bool = viewModel.isActive.value
        self.viewShadows.isHidden = true
        self.contentView.alpha = isActiveValue ? 1.0 : 0.25
        
        let holdGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SubproductAdminCell.showHoldAndEditEvent(_:)));
        holdGestureRecognizer.minimumPressDuration = 1.00;
        self.swipeContentView.addGestureRecognizer(holdGestureRecognizer);
        
        rightButtons = [deleteButton, editButton]
    }
    
    @objc func showHoldAndEditEvent(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            viewModel?.editProduct()
        }
    }
}

//
//  ServiceSelectionCell.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/31/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit

final class ServiceSelectionCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    @IBOutlet fileprivate weak var imgSelectStatus: UIImageView!
    fileprivate let disposeBag = DisposeBag()
    
    var viewModel: ServiceSelectionCellViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag.dispose()
        viewModel = nil
    }
    
    fileprivate func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        self.titleLabel.text = viewModel.title
        self.priceLabel.text = String(format:"$%.2f", viewModel.price)
        viewModel.selectStatusImage.bind(to: imgSelectStatus.bnd_image).dispose(in: disposeBag)
        self.contentView.alpha = viewModel.isActive ? 1.0 : 0.25
    }
}

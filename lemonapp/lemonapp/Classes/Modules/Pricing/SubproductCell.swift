//
//  SubproductCell.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond

final class SubproductCellViewModel: ViewModel {
    
    let title: String
    let price: Double
    
    fileprivate let service: Service
    
    init(service: Service) {
        self.service = service
        self.price = service.price
        self.title = service.name
    }
}


final class SubproductCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    
    var viewModel: SubproductCellViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    fileprivate func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        self.titleLabel.text = viewModel.title
        self.priceLabel.text = String(format:"$%.2f", viewModel.price)
    }
}

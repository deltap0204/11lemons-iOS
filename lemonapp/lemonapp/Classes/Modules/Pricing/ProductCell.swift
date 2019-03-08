//
//  ProductCell.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond

final class ProductCellViewModel: ViewModel {
    
    let title: String
    let details: String
    let image: UIImage?
    let isAccessoryViewHidden: Bool
    let subprodutsViewModel: SubproductsViewModel?
    
    fileprivate let department: Service
    init (department: Service) {
        self.department = department
        
        self.title = department.name
        self.details = department.description
        self.image = ProductHelper.getImageBy(department.id)
        
        if let services = department.typesOfService {
            self.isAccessoryViewHidden = services.count <= 0
            self.subprodutsViewModel = services.count > 0 ? SubproductsViewModel(department: department) : nil
        } else {
            self.isAccessoryViewHidden = true
            self.subprodutsViewModel = nil
        }
    }
}

final class ProductCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var detailsLabel: UILabel!
    @IBOutlet fileprivate weak var customImageView: UIImageView!
    @IBOutlet fileprivate weak var customAccessoryView: UIView!
    
    var viewModel: ProductCellViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    fileprivate func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        self.titleLabel.text = viewModel.title
        self.detailsLabel.text = viewModel.details
        self.customImageView.image = viewModel.image
        self.customAccessoryView.isHidden = viewModel.isAccessoryViewHidden
    }
}

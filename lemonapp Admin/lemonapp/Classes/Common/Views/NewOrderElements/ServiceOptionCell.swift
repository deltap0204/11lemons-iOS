//
//  ServiceOptionCell.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 9/25/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import UIKit

class ServiceOptionCell: UITableViewCell {

    
    @IBOutlet fileprivate weak var titleLbl: UILabel!
    @IBOutlet fileprivate weak var checkImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(_ title: String, isSelected: Bool) {
        titleLbl.text = title
        checkImg.isHidden = !isSelected
    }
    
}

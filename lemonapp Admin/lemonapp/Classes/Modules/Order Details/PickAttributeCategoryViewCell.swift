//
//  PickAttributeCategoryViewCell.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit

class PickAttributeCategoryViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    var category: Category?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

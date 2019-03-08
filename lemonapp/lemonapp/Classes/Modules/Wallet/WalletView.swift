//
//  WalletView.swift
//  lemonapp
//
//  Created by Svetlana Dedunovich on 5/6/16.
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond


final class WalletView: UIToolbar {
    
    @IBOutlet var balanceButton: UIButton!
    
    var viewModel: UserViewModel? {
        didSet {
            if let viewModel = viewModel {
                bindViewModel(viewModel)
            } else {
                //balanceButton.bnd_title.next("")
                //balanceButton.titleLabel?.text = ""
                viewModel?.balance.next("")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //balanceButton.bnd_title.next("")
        //balanceButton.titleLabel?.text = ""
        viewModel?.balance.next("")
        balanceButton.layer.cornerRadius = 15
    }
    
    fileprivate func bindViewModel(_ viewModel: UserViewModel) {
        viewModel.balance.bind(to: balanceButton.bnd_title)
    }
}

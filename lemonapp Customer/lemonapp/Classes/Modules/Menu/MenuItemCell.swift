//
//  MenuItemCell.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond

final class MenuItemCell : UITableViewCell {
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var iconView: UIImageView!
    @IBOutlet fileprivate weak var customBackgroundView: UIView!
    @IBOutlet fileprivate weak var badgeView: UIView!
    @IBOutlet fileprivate weak var badgeLabel: UILabel!
    
    fileprivate var menuItemObserver: Observable<MenuItem?> = Observable(nil)
    
    var menuItem: MenuItem? {
        didSet {
            self.menuItemObserver.value = menuItem
            if let menuItem = menuItem {
                titleLabel.text = menuItem.title ?? ""
                iconView.image = UIImage(assetIdentifier: menuItem.iconAssetId).withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                if menuItem == .UserDashboard {
                    self.bindDashboard()
                } else if menuItem == .CloudCloset {
                    self.bindCloud()
                }
            }
        }
    }
    private func bindCloud() {
        let cloudClosetBandage = DataProvider.sharedInstance.cloudClosetUpdates
        
        cloudClosetBandage.map { "\($0)"}.bind(to: self.badgeLabel.bnd_text)
        cloudClosetBandage.map { $0 == 0 }.bind(to: self.badgeView.bnd_hidden)
    }
    
    private func bindDashboard() {
        let dataProvider = DataProvider.sharedInstance
        let dashboardBandage = dataProvider.userOrdersUpdates
        .combineLatest(with: dataProvider.walletUpdates)
        .map { return $0 + $1 }
        
        dashboardBandage.map { "\($0)"}.bind(to: self.badgeLabel.bnd_text)
        dashboardBandage.map { $0 == 0 }.bind(to: self.badgeView.bnd_hidden)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconView.tintColor = UIColor.black
        self.badgeView.isHidden = true

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            customBackgroundView.isHidden = false
            customBackgroundView.alpha = 1
            titleLabel.textColor = UIColor.white
            iconView.tintColor = UIColor.white
            badgeView.backgroundColor = UIColor.white
            badgeLabel.textColor = UIColor.appBlueColor
        } else {
            customBackgroundView.isHidden = true
            titleLabel.textColor = UIColor.black
            iconView.tintColor = UIColor.black
            badgeView.backgroundColor = UIColor.appBlueColor
            badgeLabel.textColor = UIColor.white
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            customBackgroundView.isHidden = false
            customBackgroundView.alpha = 0.75
            titleLabel.textColor = UIColor.white
            iconView.tintColor = UIColor.white
        } else {
            customBackgroundView.isHidden = true
            titleLabel.textColor = UIColor.black
            iconView.tintColor = UIColor.black
        }
    }
}

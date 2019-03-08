//
//  OrderCell.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation
import UIKit
import MGSwipeTableCell
import Bond

enum UtilsButtonType: Int {
    case cancelOrder = 100
    case archiveOrder = 101
}

final class OrderCell : MGSwipeTableCell {
    
    var viewModel: OrderCellViewModel? {
        didSet {
            idLabel.text = viewModel?.orderId
            deliveryLabel.text = viewModel?.deliveryStatus
            statusLabel.text = viewModel?.orderStatus.subtitle
            dateLabel.text = viewModel?.statusCahngedDate
            messageButton.isHidden = !(viewModel?.shouldMessageButtons ?? false)
            phoneButton.isHidden =  !(viewModel?.shouldPhoneButtons ?? false)
            statusImageView.image = viewModel?.statusImage
            customAccessoryView.isHidden = !(viewModel?.shouldAccessoryArrow ?? false)
            
            if (viewModel?.canCancel ?? false) || (viewModel?.canArchive ?? false) {
                self.rightButtons = [(viewModel?.canArchive ?? false) ? archiveButton : cancelButton]
            } else {
                self.rightButtons = []
            }
            rightSwipeSettings.transition = .clipCenter
            
            let updated = viewModel?.updated.value ?? false
            
            self.updatedLabel.isHidden = !updated
            updateStatus()
        }
    }
    
    @IBOutlet fileprivate weak var deliveryLabel: UILabel!
    @IBOutlet fileprivate weak var statusLabel: UILabel!
    @IBOutlet fileprivate weak var idLabel: UILabel!
    @IBOutlet fileprivate weak var highlightedBackground: UIView!
    @IBOutlet fileprivate weak var customAccessoryView: UIView!
    @IBOutlet fileprivate weak var changedStatusIndecatorAccessoryView: UIView!
    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet fileprivate weak var statusImageView: UIImageView!
    @IBOutlet fileprivate weak var updatedLabel: UIView!
    
    let cancelButton: UIButton
    let archiveButton: UIButton
    
    let isUtilsOpen = Observable(false)
    
    required init?(coder aDecoder: NSCoder) {
        cancelButton = Bundle.main.loadNibNamed("CancelOrderButton", owner: nil, options: nil)!.first! as! UIButton
        archiveButton = Bundle.main.loadNibNamed("ArchiveOrderButton", owner: nil, options: nil)!.first! as! UIButton
        super.init(coder: aDecoder)        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        preservesSuperviewLayoutMargins = false
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        highlightedBackground.isHidden = !highlighted
        if highlighted {
            self.updateStatus()
            UIView.animate(withDuration: 0.4, animations: {
                self.updatedLabel.alpha = 0
            }, completion: { [weak self] _ in
                self?.updatedLabel.isHidden = true
                self?.updatedLabel.alpha = 1
            }) 
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
        highlightedBackground.isHidden = !selected
    }
    
    fileprivate func updateStatus() {
        self.changedStatusIndecatorAccessoryView.isHidden = viewModel?.viewed.value ?? true
        self.statusLabel.textColor = viewModel?.statusColor
        self.viewModel?.viewed.value = true
        viewModel?.updated.value = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag.dispose()
    }
}

protocol OrderCellDelegate {
    func orderCellMessageDidTap(_ oredrCell: OrderCell)
}

//
//  WalletTransitionCell.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import Bond

final class WalletTransitionCell: MGSwipeTableCell {
    
    var viewModel: WalletTransitionCellViewModel? {
        didSet {
            //            typeLabel.text = viewModel?.type
            notesLabel.text = viewModel?.notes
            dateLabel.text = viewModel?.date
            if let amount = viewModel?.amount {
                amountLabel.text = amount + " Added"
            }
            typeLabel.text = viewModel?.typeName
            typeImageView.image = viewModel?.transitionTypeImage
            customAccessoryView.isHidden = !(viewModel?.shouldAccessoryView ?? false)
            changedStatusIndecatorAccessoryView.isHidden = viewModel?.viewed ?? true
            amountLabel.textColor = viewModel?.titleColorLabel
            viewModel?.viewed = true
        }
    }
    
    @IBOutlet fileprivate weak var notesLabel: UILabel!
    @IBOutlet fileprivate weak var amountLabel: UILabel!
    @IBOutlet fileprivate weak var typeLabel: UILabel!
    @IBOutlet fileprivate weak var highlightedBackground: UIView!
    @IBOutlet fileprivate weak var changedStatusIndecatorAccessoryView: UIView!
    @IBOutlet fileprivate weak var customAccessoryView: UIView!
    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet fileprivate weak var typeImageView: UIImageView!
    
    let isUtilsOpen = Observable(false)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let archiveButton = Bundle.main.loadNibNamed("ArchiveOrderButton", owner: nil, options: nil)!.first! as! UIButton
        self.rightButtons = [archiveButton]
        self.rightSwipeSettings.transition = .clipCenter
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
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
        highlightedBackground.isHidden = !selected
    }
}

//
//  AdminOrderCell.swift
//  lemonapp
//
//  Created by Vova Tanakov on 10/4/16.
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond
import MGSwipeTableCell
import ReactiveKit

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class AdminOrderCell : MGSwipeTableCell {
    
    @IBOutlet fileprivate weak var deliveryLabel: UILabel!
    @IBOutlet fileprivate weak var statusLabel: UILabel!
    @IBOutlet fileprivate weak var idLabel: UILabel!
    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet fileprivate weak var highlightedBackground: UIView!
    @IBOutlet fileprivate weak var statusView: UIView!
    @IBOutlet weak var avatarBackgroundView: UIView!
    @IBOutlet fileprivate weak var avatarImageView: UIImageView!
    @IBOutlet fileprivate weak var avatarPlaceholder: UILabel!
    @IBOutlet weak var countdownTimer: UILabel!
    @IBOutlet fileprivate weak var plView: UIView!
    
    @IBOutlet fileprivate weak var lblBadgeTotal: UILabel!
    @IBOutlet fileprivate weak var imgBadge: UIImageView!
    @IBOutlet fileprivate weak var viewBadge: UIView!
    @IBOutlet weak var lblBadgeStart: UILabel!
    @IBOutlet weak var imgForward: UIImageView!
    @IBOutlet weak var badgeActicity: UIActivityIndicatorView!
    
    let nextStatusButton: UIButton

    let orderStatusButton: UIButton
    let noteButton: UIButton
    let callButton: UIButton
    let disposeBag = DisposeBag()
    var isTimerVisible = false
    
    override func prepareForReuse() {
        disposeBag.dispose()
    }
    
    var viewModel: AdminOrderCellViewModel? {
        didSet {
            
            isTimerVisible = false
            updateTimerVisibility(isTimerVisible)
            viewModel?.avatarBackgroundColor.bind(to: avatarBackgroundView.bnd_backgroundColor).dispose(in: self.disposeBag)
            
            let avatarOverlay = UIView(frame: avatarBackgroundView.bounds)
            avatarOverlay.backgroundColor = UIColor.clear
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(AdminOrderCell.changeTimerVisibility(_:)))
            tapRecognizer.numberOfTapsRequired = 1
            avatarOverlay.addGestureRecognizer(tapRecognizer)
            avatarBackgroundView.addSubview(avatarOverlay)

            if viewModel?.orderStatus == .awaitingPickup || viewModel?.orderStatus == .outForDelivery {
                statusLabel.text = (viewModel?.order.createdBy?.firstName ?? "") + " " + (viewModel?.order.createdBy?.lastName ?? "")
                var street = ""
                var aptSuite = ""
                if viewModel?.orderStatus == .awaitingPickup {
                    street = viewModel?.order.delivery.pickupAddress?.street ?? " "
                    aptSuite = viewModel?.order.delivery.pickupAddress?.aptSuite ?? " "
                } else {
                    street = viewModel?.order.delivery.dropoffAddress?.street ?? " "
                    aptSuite = viewModel?.order.delivery.dropoffAddress?.aptSuite ?? " "
                }
                
                idLabel.text = street
                if !aptSuite.isEmpty {
                    idLabel.text = idLabel.text! + " Apt \(aptSuite)"
                }
                
                deliveryLabel.text = viewModel?.orderId
            } else {
                statusLabel.text = viewModel?.orderStatus.subtitle
                idLabel.text = viewModel?.orderId
                deliveryLabel.text = viewModel?.deliveryStatus
            }
            dateLabel.text = viewModel?.statusChangedDate

            avatarImageView.cornerRadius = avatarImageView.frame.height / 2
            
            viewModel?.avatarImage.bind(to: avatarImageView.bnd_image).dispose(in: self.disposeBag)
            viewModel?.avatarImage.bind(signal: (viewModel?.photoRequest)!).dispose(in: self.disposeBag)
            viewModel!.showStartBadge.observeNext { [weak self] value in
                guard let strongSelf = self else { return }
                if value {
                    strongSelf.lblBadgeStart.isHidden = false
                    strongSelf.imgForward.isHidden = false
                    strongSelf.imgBadge.isHidden = true
                    strongSelf.lblBadgeTotal.isHidden = true
                } else {
                    strongSelf.lblBadgeStart.isHidden = true
                    strongSelf.imgForward.isHidden = true
                    strongSelf.imgBadge.isHidden = false
                    strongSelf.lblBadgeTotal.isHidden = false
                }
                }.dispose(in: self.disposeBag)
            
            viewModel?.orderTotal.observeNext(with: { [weak self] (value) in
                if value <= 0 {
                    
                    self?.imgBadge.isHidden = true
                    self?.badgeActicity.isHidden = false
                    self?.badgeActicity.startAnimating()
                } else {
                    self?.imgBadge.isHidden = false
                    self?.badgeActicity.isHidden = true
                    self?.badgeActicity.stopAnimating()
                }
            }).dispose(in: self.disposeBag)
            viewModel?.orderTotal.map { $0 <= 0 ? "" : String(format: "$%.2f", $0)}.bind(to: lblBadgeTotal.bnd_text).dispose(in: self.disposeBag)
            viewBadge.backgroundColor = viewModel?.statusColor
            
            viewModel?.processStatus.observeNext(with: { [weak self] (processStatus) in
                guard let processStatus = processStatus, let strongSelf = self else {return}
                DispatchQueue.main.async {
                switch processStatus {
                case .processing:
                    strongSelf.badgeActicity.isHidden = false
                    strongSelf.badgeActicity.startAnimating()
                    strongSelf.imgBadge.isHidden = true
                    strongSelf.viewBadge.isHidden = false
                    strongSelf.lblBadgeStart.isHidden = true
                    strongSelf.lblBadgeTotal.isHidden = true
                    strongSelf.imgForward.isHidden = true
                case .accepted:
                    strongSelf.badgeActicity.stopAnimating()
                    strongSelf.viewBadge.isHidden = false
                    let isShowStartBadge = strongSelf.viewModel?.showStartBadge.value ?? false
                    if isShowStartBadge {
                        strongSelf.lblBadgeStart.isHidden = false
                        strongSelf.imgForward.isHidden = false
                        strongSelf.imgBadge.isHidden = true
                        strongSelf.lblBadgeTotal.isHidden = true
                    } else {
                        strongSelf.lblBadgeStart.isHidden = true
                        strongSelf.imgForward.isHidden = true
                        strongSelf.imgBadge.isHidden = false
                        strongSelf.lblBadgeTotal.isHidden = false
                    }
                    strongSelf.viewBadge.backgroundColor = OrderPaymentStatus.paymentProcessedSuccessfully.color
                    strongSelf.imgBadge.image = OrderPaymentStatus.paymentProcessedSuccessfully.icon
                case .failed:
                    strongSelf.badgeActicity.stopAnimating()
                    strongSelf.viewBadge.isHidden = false
                    let isShowStartBadge = strongSelf.viewModel?.showStartBadge.value ?? false
                    if isShowStartBadge {
                        strongSelf.lblBadgeStart.isHidden = false
                        strongSelf.imgForward.isHidden = false
                        strongSelf.imgBadge.isHidden = true
                        strongSelf.lblBadgeTotal.isHidden = true
                    } else {
                        strongSelf.lblBadgeStart.isHidden = true
                        strongSelf.imgForward.isHidden = true
                        strongSelf.imgBadge.isHidden = false
                        strongSelf.lblBadgeTotal.isHidden = false
                    }
                    strongSelf.viewBadge.backgroundColor = OrderPaymentStatus.ccDecline.color
                    strongSelf.imgBadge.image = OrderPaymentStatus.ccDecline.icon
                case .failedAndProcessing:
                    strongSelf.badgeActicity.isHidden = false
                    strongSelf.badgeActicity.startAnimating()
                    strongSelf.imgBadge.isHidden = true
                    strongSelf.lblBadgeTotal.isHidden = true
                    strongSelf.viewBadge.isHidden = false
                    strongSelf.lblBadgeStart.isHidden = true
                    strongSelf.imgForward.isHidden = true
                    strongSelf.viewBadge.backgroundColor = OrderPaymentStatus.ccDecline.color
                    strongSelf.imgBadge.image = OrderPaymentStatus.ccDecline.icon
                case .error:
                    strongSelf.badgeActicity.stopAnimating()
                    strongSelf.viewBadge.isHidden = false
                    let isShowStartBadge = strongSelf.viewModel?.showStartBadge.value ?? false
                    if isShowStartBadge {
                        strongSelf.lblBadgeStart.isHidden = false
                        strongSelf.imgForward.isHidden = false
                        strongSelf.imgBadge.isHidden = true
                        strongSelf.lblBadgeTotal.isHidden = true
                    } else {
                        strongSelf.lblBadgeStart.isHidden = true
                        strongSelf.imgForward.isHidden = true
                        strongSelf.imgBadge.isHidden = false
                        strongSelf.lblBadgeTotal.isHidden = false
                    }
                    strongSelf.viewBadge.backgroundColor = UIColor.paymentErrorColor
                }
                }
            }).dispose(in: self.disposeBag)
            
            let gestureSwift2AndHigher = UITapGestureRecognizer(target: self, action:  #selector (self.onBadgeView (_:)))
            viewBadge.addGestureRecognizer(gestureSwift2AndHigher)
            
            
            viewModel!.statusImage.observeNext { [weak self] image in
                self?.imgBadge.image = image
            }.dispose(in: self.disposeBag)
            
            viewModel?.avatarImage.observeNext { [weak self] value in
                self?.avatarPlaceholder.isHidden = value != nil
                
            }.dispose(in: self.disposeBag)
            if let user = viewModel?.order.lastModifiedUser {
                avatarPlaceholder.text = getInitialsFromUser(user)
            } else {
                if let user = viewModel?.order.createdBy {
                    avatarPlaceholder.text = getInitialsFromUser(user)
                }
            }
            
            if let viewModel = viewModel, (viewModel.orderStatus == .awaitingPickup || viewModel.orderStatus == .outForDelivery) {
                rightButtons = [callButton, noteButton, orderStatusButton]
            } else {
                rightButtons = [noteButton, orderStatusButton]
            }
            rightSwipeSettings.transition = .clipCenter
            
            leftButtons = [nextStatusButton]
            leftExpansion.buttonIndex = 0
            leftExpansion.fillOnTrigger = true
            leftSwipeSettings.transition = .clipCenter

            updateStatus()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        orderStatusButton = Bundle.main.loadNibNamed("OrderStatusButton", owner: nil, options: nil)!.first! as! UIButton
        noteButton = Bundle.main.loadNibNamed("AddNoteButton", owner: nil, options: nil)!.first! as! UIButton
        callButton = Bundle.main.loadNibNamed("CallButton", owner: nil, options: nil)!.first! as! UIButton
        nextStatusButton = Bundle.main.loadNibNamed("NextStatusButton", owner: nil, options: nil)!.first! as! UIButton
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        preservesSuperviewLayoutMargins = false
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        
        plView.layer.cornerRadius = plView.frame.width/2
        plView.clipsToBounds = true
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        highlightedBackground.isHidden = !highlighted
        if highlighted {
            self.updateStatus()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
        highlightedBackground.isHidden = !selected
    }
    
    fileprivate func updateStatus() {
        self.statusView.isHidden = viewModel?.viewed.value ?? true
        self.statusLabel.textColor = UIColor.white
        self.viewModel?.viewed.value = true
        viewModel?.updated.value = false
        updateNextStatusButtonState()
    }
    
    fileprivate func updateNextStatusButtonState() {
        var icon: UIImage? = nil
        var title = "Undefined"
        if let orderStatus = viewModel?.order.status, let nextOrderStatus = orderStatus.nextStatus {
            if orderStatus == .atFacility && viewModel?.order.orderAmount.amount <= 0 {
                icon = UIImage(named: "ic_receipt")
                title = "Start Order"
            } else {
                icon = nextOrderStatus.image
                title = nextOrderStatus.subtitle
            }
        }
        nextStatusButton.setTitle(title, for: UIControlState())
        nextStatusButton.setImage(icon, for: UIControlState())
    }

    fileprivate func getInitialsFromUser(_ user: User) -> String {
        var userInitials: String = user.firstName.substring(to: user.firstName.index(user.firstName.startIndex, offsetBy: 1))
        userInitials += user.lastName.substring(to: user.lastName.index(user.lastName.startIndex, offsetBy: 1))
        userInitials = userInitials.uppercased()
        return userInitials
    }

    @objc func changeTimerVisibility(_ sender: AnyObject?) {
        isTimerVisible = !isTimerVisible
        updateTimerVisibility(isTimerVisible)
    }

    func updateTimerVisibility(_ isVisible: Bool) {
        avatarImageView.isHidden = isVisible
        if (avatarImageView.image == nil) {
            avatarPlaceholder.isHidden = isVisible
        }
        countdownTimer.isHidden = !isVisible
    }
    
    @objc func onBadgeView(_ sender:UITapGestureRecognizer) {
        viewModel?.onBadgeView()
    }
}

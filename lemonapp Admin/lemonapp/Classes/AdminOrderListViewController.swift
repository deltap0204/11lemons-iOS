//
//  AdminOrderListViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond
import DrawerController
import PassKit
import MessageUI
import BTNavigationDropdownMenu
import MGSwipeTableCell

class AdminOrderListViewController: UIViewController {

    @IBOutlet fileprivate weak var searchBar: UISearchBar!
    @IBOutlet fileprivate weak var searchBarHeight: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var nextPickupView: NextPickupView!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var sortButton: UIButton!
    @IBOutlet fileprivate weak var locationButton: UIButton!
//    @IBOutlet fileprivate weak var newOrderButton: OrderButton!
    
    let viewModel = AdminOrderListViewModel()
    var router: OrderListRouter?
    fileprivate var prevCellIndexPath: IndexPath? = nil
    fileprivate var timer: Timer?
    
    @IBOutlet weak var feedbackView: UIView!
    @IBOutlet weak var feedbackLeftBtn: UIButton!
    @IBOutlet weak var feedbackRightbtn: UIButton!
    @IBOutlet weak var feedbackLeftLabel: UILabel!
    @IBOutlet weak var feedbackBarConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self

        searchBar.delegate = self
        
        let nib = UINib(nibName: "AdminOrderCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AdminOrderCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController,
                                                containerView: self.navigationController!.view,
                                                title: viewModel.headerItems[0],
                                                items: viewModel.headerItems)
        menuView.didSelectItemAtIndexHandler = { [weak self] (indexPath: Int) -> () in
            self?.viewModel.pickedHeaderIndex.value = indexPath
        }
        self.navigationItem.titleView = menuView
        
        viewModel.dashboardViewModels.filter({ self.viewModel.filterOrders($0) }).bind(to: tableView) { [weak self] dataSource, indexPath, tableView in
            //TODO migration-check
            //TODO tableview-migration
            //Before migration code
            
            if let orderCellViewModel = dataSource[indexPath.row] as? AdminOrderCellViewModel {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AdminOrderCell", for: indexPath)
                if let orderCell = cell as? AdminOrderCell {
                    orderCellViewModel.navigationDelegate = self
                    orderCell.viewModel = orderCellViewModel
                    orderCell.delegate = self
                    
                    return orderCell
                }
                return cell
            }
            return UITableViewCell(style: .default, reuseIdentifier: "")
        }
        
        viewModel.pickedHeaderIndex.observe{ [weak self] (value) in
            if let array = self?.viewModel.dashboardViewModels.array {
                self?.viewModel.dashboardViewModels.replace(with: array)
            }
        }
        
        DataProvider.sharedInstance.pickupETA.bind(to: viewModel.pickupETA)
        
        viewModel.pickupETA.observeNext { [weak self] (value) in
            self?.nextPickupView.setTitle(String.init(format: "%d", value), subtitle: "MIN", allowEditing: true)
            return
        }
        
        sortButton.bnd_tap.observeNext { [weak self] in
            if let strongSelf = self, let array = self?.viewModel.dashboardViewModels.array {
                strongSelf.viewModel.orderedAscending = !strongSelf.viewModel.orderedAscending
                strongSelf.viewModel.dashboardViewModels.replace(with: array.sorted(by: { strongSelf.viewModel.sortOrders($0, object2:$1) }))
            }
        }
        
        viewModel.update()

        let holdGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(AdminOrderListViewController.showSnoozeAlert(_:)));
        holdGestureRecognizer.minimumPressDuration = 1.00;
        tableView?.addGestureRecognizer(holdGestureRecognizer);
        
        NotificationCenter.default.addObserver(self, selector: #selector(AdminOrderListViewController.TokenAdded), name: notificationNameToken, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.navigationController as? YellowNavigationController)?.barStyle.value = .yellow
        
        viewModel.update {
            self.tableView.reloadData()
            self.tableView.alpha = 1
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerTick), userInfo: nil, repeats: true)
        nextPickupView.startAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
        if nextPickupView != nil {
            nextPickupView.stopAnimation()
        }
        super.viewDidDisappear(animated)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return navigationController?.prefersStatusBarHidden ?? false
    }
    
    @objc func TokenAdded() {
        viewModel.update()
    }
    
    @IBAction func leftbarButtonClick(_ sender: AnyObject) {
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    @IBAction func rightBarButtonClick(_ sender: AnyObject) {
        toggleSearchBar()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        viewModel.update { [weak refreshControl] in
            refreshControl?.endRefreshing()
        }
    }

    @objc func showSnoozeAlert(_ sender: UILongPressGestureRecognizer) {
        if sender.state != .began {
            return
        }

        let point = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if let ip = indexPath, let cell = tableView.cellForRow(at: ip) as? AdminOrderCell, let viewModel = cell.viewModel {
            self.viewModel.snoozeOrder(viewModel.order, fromViewController: self)
        }
    }

    @objc fileprivate func timerTick() {
        self.tableView?.visibleCells.forEach({ cell in
            if let cell = (cell as? AdminOrderCell), let viewModel = cell.viewModel {
                let date: Date?
                if viewModel.order.status == .awaitingPickup {
                    date = viewModel.order.delivery.estimatedPickupDate
                } else {
                    date = viewModel.order.delivery.estimatedArrivalDate
                }

                if let date = date {
                    var minutes = date.minutesFrom(Date())
                    var seconds = date.secondsFrom(Date()) % 60
                    if minutes >= 30 {
                        cell.avatarBackgroundView.backgroundColor = UIColor.appBlueColor
                        cell.countdownTimer.text = "\(minutes):\(seconds < 10 ? "0\(seconds)" : "\(seconds)")"
                    } else if minutes >= 0 && seconds >= 0 {
                        cell.avatarBackgroundView.backgroundColor = UIColor.appYellowColor()
                        cell.countdownTimer.text = "\(minutes):\(seconds < 10 ? "0\(seconds)" : "\(seconds)")"
                    } else {
                        cell.avatarBackgroundView.backgroundColor = UIColor.appRedColor()
                        minutes = abs(minutes)
                        seconds = abs(seconds)
                        cell.countdownTimer.text = "+\(minutes):\(seconds < 10 ? "0\(seconds)" : "\(seconds)")"
                    }
                }
            }
        })
        self.forcePickupETAUpdate()
    }

    fileprivate func forcePickupETAUpdate() {
        viewModel.pickupETA.next(viewModel.pickupETA.value)
    }
    
    func toggleSearchBar() {
        UIView.animate(withDuration: 1, animations: {[weak self] in
            if (self?.searchBarHeight.constant == 0) {
                self?.searchBarHeight.constant = 44
            } else {
                self?.searchBarHeight.constant = 0
            }
            self?.view.layoutIfNeeded()
            }, completion: { [weak self] (value) in
                self?.searchBar.resignFirstResponder()
            })
    }
    
    
    @IBAction func onFeedbackRight(_ sender: UIButton) {
        if sender.titleLabel!.text! == "DISMISS" {
            self.hideFeedback()
        } else if sender.titleLabel!.text! == "NOTIFY" {
            self.hideFeedback()
            self.viewModel.sendNotification()
        } else if sender.titleLabel!.text! == "RETRY" {
            
            self.viewModel.retryPaymentProcess()
            self.hideFeedback()
        }
    }
    
    @IBAction func onFeedbackLeft(_ sender: UIButton) {
        if sender.titleLabel!.text! == "RETRY" {
            self.viewModel.retryPaymentProcess()
            self.hideFeedback()
        }
    }
}

extension AdminOrderListViewController: MGSwipeTableCellDelegate {

    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }

    func swipeTableCell(_ cell: MGSwipeTableCell!, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        guard let viewModel = (cell as? AdminOrderCell)?.viewModel else {
            return true
        }

        if direction == .leftToRight {
            if viewModel.order.status == .atFacility && viewModel.order.orderAmount.amount <= 0 {
                router?.showOrderServicesFlow(viewModel.order)
            } else {
                if let indexViewModel = self.viewModel.dashboardItems.array.index(where: {$0.id == viewModel.order.id}) {
                    self.viewModel.dashboardItems.remove(at: indexViewModel)
                }
                self.viewModel.bumpOrderStatus(viewModel.order, fromViewController: self)
            }
            
            return true;
        }

        //3 buttons
        if viewModel.orderStatus == .awaitingPickup || viewModel.orderStatus == .outForDelivery {
            switch index {
            case 0:
                self.viewModel.callToOrderCreator(viewModel.order, fromViewController: self)
                break
            case 1:
                self.viewModel.addNoteToOrder(viewModel.order, fromViewController: self)
                break
            case 2:
                self.viewModel.changeOrderStatus(viewModel.order, fromViewController: self)
                break
            default:
                break
            }
        } else {
            //2 buttons
            switch index {
            case 0:
                self.viewModel.addNoteToOrder(viewModel.order, fromViewController: self)
                break
            case 1:
                self.viewModel.changeOrderStatus(viewModel.order, fromViewController: self)
                break
            default:
                break
            }
        }
        return true //Autohide on click
    }
}

extension AdminOrderListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) as? AdminOrderCell,
            let order = cell.viewModel?.order {
            // order.status == .AwaitingPickup {
            router?.showEditOrderFlow(order)
        }
    }
}

extension AdminOrderListViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension AdminOrderListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.reorderBySearchString(searchText)
    }
}

extension AdminOrderListViewController: AdminOrderCellNavigationDelegate {
    func receiptDetailOf(_ order: Order) {
        router?.showOrderrReceiptFlow(order)
    }
    
    func completeDetailOf(_ order: Order) {
        router?.showOrderServicesFlow(order)
    }
}

extension AdminOrderListViewController: AdminOrderListViewModelDelegate {
    func showAcceptedNotificationbar() {
        DispatchQueue.main.async {
            self.feedbackLeftBtn.isHidden = true
            self.feedbackView.backgroundColor = UIColor("#007AFF")
            self.feedbackLeftLabel.text = "Payment Successful."
            self.feedbackRightbtn.setTitle("DISMISS")
            self.showFeedback()
        }
    }
    
    func showDeclinedNotificationbar() {
        DispatchQueue.main.async {
            self.feedbackView.backgroundColor = UIColor("#D50000FF")
            self.feedbackLeftLabel.text = "Payment Declined"
            self.feedbackLeftBtn.isHidden = false
            self.feedbackLeftBtn.setTitle("RETRY")
            self.feedbackRightbtn.setTitle("NOTIFY")
            self.showFeedback()
        }
    }
    
    func showFinalDeclinedNotificationbar() {
        DispatchQueue.main.async {
            self.feedbackView.backgroundColor = UIColor("#D50000FF")
            self.feedbackLeftLabel.text = "Payment Declined."
            self.feedbackLeftBtn.isHidden = true
            self.feedbackRightbtn.setTitle("NOTIFY")
            self.showFeedback()
        }
    }
    
    func showNotificationSent() {
        DispatchQueue.main.async {
            self.feedbackLeftBtn.isHidden = true
            self.feedbackView.backgroundColor = UIColor("#007AFF")
            self.feedbackLeftLabel.text = "Notification Sent."
            self.feedbackRightbtn.setTitle("DISMISS")
            self.showFeedback()
        }
    }
    
    func showErrorNotificationbar() {
        DispatchQueue.main.async {
            self.feedbackView.backgroundColor = UIColor("#FD9426")
            self.feedbackLeftLabel.text = "Payment Error."
            self.feedbackLeftBtn.isHidden = true
            self.feedbackRightbtn.setTitle("RETRY")
            self.showFeedback()
        }
    }
    
    fileprivate func showFeedback() {
        feedbackBarConstraint.constant = 0
        UIView.animate(withDuration: 0.6,
                       animations: {
                        self.feedbackView.alpha = 1.0
                        self.view.layoutIfNeeded()
        })
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(5.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.hideFeedback()
        }
    }
    
    fileprivate func hideFeedback() {
        self.viewModel.nextRetryID = nil
        feedbackBarConstraint.constant = -50
        UIView.animate(withDuration: 0.6,
                       animations: {
                        self.feedbackView.alpha = 0
                        self.view.layoutIfNeeded()
        })
    }
}

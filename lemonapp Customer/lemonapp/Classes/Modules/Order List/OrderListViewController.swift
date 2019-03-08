//
//  OrderListViewController.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond
import DrawerController
import MGSwipeTableCell
import PassKit
import MessageUI
import ReactiveKit

class OrderListViewController : UIViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var walletView: WalletView!
    @IBOutlet fileprivate weak var walletViewBottomSeparator: UIView!
    @IBOutlet var walletContainerStackView: UIStackView!
    
    
    @IBOutlet fileprivate weak var nextPickupView: NextPickupView!
    @IBOutlet fileprivate weak var nextPickupViewContainer: UIView!
    @IBOutlet fileprivate weak var nextPickupViewSeparator: UIView!
    
    @IBOutlet fileprivate weak var hintLabel: UILabel!
    @IBOutlet fileprivate weak var newOrderButton: OrderButton!
    @IBOutlet var newOrderBtnHeight: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var menuButton: UIBarButtonItem!
    
    fileprivate var timer: Timer?
    fileprivate var transition: TutorialOverlayTransition?
    fileprivate let disposeBag = DisposeBag()
    var router: OrderListRouter?
    
    let viewModel = OrderListViewModel()
    fileprivate var prevCellIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: newOrderBtnHeight, baseValue: 60)
        
        viewModel.isNewItems.map { UIImage(named: $0 ? "ic_menu_new_items" : "ic_menu_icon")?.withRenderingMode(.alwaysOriginal) }.bind(to: menuButton.bnd_image)
        
        viewModel.dashboardViewModels.bind(to: tableView) { [weak self] dataSource, indexPath, tableView in

            //TODO migration-check
            //TODO tableview-migration
            //Before migration code
            
            
            if let orderCellViewModel = dataSource/*[indexPath.section]*/[indexPath.row] as? OrderCellViewModel {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                if let orderCell = cell as? OrderCell {
                    orderCell.phoneButton.removeTarget(self, action: nil, for: .touchUpInside)
                    orderCell.phoneButton.addTarget(self, action: #selector(OrderListViewController.phone), for: .touchUpInside)
                    orderCell.messageButton.removeTarget(self, action: nil, for: .touchUpInside)
                    orderCell.messageButton.addTarget(self, action: #selector(OrderListViewController.sendMessage), for: .touchUpInside)
                    orderCell.viewModel = orderCellViewModel
                    orderCell.delegate = self
                    return orderCell
                }
                return cell
            } else if let walletTransitionCellViewModel = dataSource/*[indexPath.section]*/[indexPath.row] as? WalletTransitionCellViewModel {
                let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTransitionCell", for: indexPath)
                if let walletCell = cell as? WalletTransitionCell {
                    walletCell.viewModel = walletTransitionCellViewModel
                    walletCell.delegate = self
                    return walletCell
                }
                return cell
            }
 
            return UITableViewCell(style: .default, reuseIdentifier: "")
        }
        
        
        /*
 viewModel.dashboardItems.observeNext { [weak self] value in
 self?.nextPickupViewSeparator.isHidden = value.sequence.count == 0
 }
 */
        viewModel.dashboardItems.observeNext { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.nextPickupViewSeparator.isHidden = result.dataSource.array.count == 0
        }.dispose(in: disposeBag)
        
        
        viewModel.walletViewModel.observeNext { [weak self] in self?.walletView.viewModel = $0 }.dispose(in: disposeBag)

        
        viewModel.shouldHideHints.bind(to: hintLabel.bnd_hidden)
        
        viewModel.newAddressAction = { [weak self] completion in
            
            self?.performSegueWithIdentifier(.Address)
            self?.viewModel.commonAddressContainerViewModel?.result.skip(first: 1).observeNext { [weak self] in
                if let address = $0 as? Address {
                    completion(address)
                } else {
                    self?.newOrderButton?.bnd_mode.value = .defaultButton
                }
            }
        }
        
        viewModel.newPaymentCardAction = { [weak self] completion in
            
            self?.performSegueWithIdentifier(.PaymentCard)
            self?.viewModel.commonPaymentCardContainerViewModel?.result.skip(first: 1).observeNext { [weak self] in
                if let paymentCard = $0 as? PaymentCard {
                    completion(paymentCard)
                } else {
                    self?.newOrderButton?.bnd_mode.value = .defaultButton
                }
            }
        }
        
        viewModel.quickOrderCanceled/*.skip(first: 1)*/.observeNext { [weak newOrderButton] in
            newOrderButton?.bnd_mode.value = .defaultButton
        }.dispose(in: disposeBag)
        
        viewModel.quickOrderCreated/*.skip(first: 1)*/.observeNext { [weak self] in
            if let strongSelf = self {
                strongSelf.viewModel.sendOrder.execute { result in
                    do {
                        let order = try result()

                        DataProvider.sharedInstance.userOrders.insert(order, at: 0)
                        strongSelf.viewModel.update {
                            strongSelf.tableView.reloadData()
                        }
                        AlertView().showInView(strongSelf.navigationController?.view) {
                            
                            if let alert = DataProvider.sharedInstance.suggestNotificationsAlert() {
                                
                                if let navigation = self?.navigationController as? YellowNavigationController {
                                    navigation.hideStatusBar.next(true)
                                    
                                    alert.completion = { turnOn in
                                        if turnOn {
                                            DataProvider.sharedInstance.registerForPushes()
                                        }
                                        DataProvider.sharedInstance.setDidShowNotifications()
                                        alert.dismiss(animated: true, completion: nil)
                                        navigation.hideStatusBar.next(false)
                                    }
                                    
                                    self?.transition = TutorialOverlayTransition()
                                    alert.modalPresentationStyle = .overFullScreen
                                    alert.transitioningDelegate = self?.transition
                                    
                                    self?.navigationController?.present(alert, animated: true, completion: nil)
                                }
                            }
                            self?.newOrderButton.bnd_mode.value = .defaultButton
                        }
                    } catch let error as BackendError {
                        print(error.message)
                        self?.handleError(error)
                    } catch {}
                }
            }
            
        }.dispose(in: disposeBag)
        
        newOrderButton.bnd_tap.observeNext { [weak self] in
            self?.router?.showNewOrderFlow()
        }.dispose(in: disposeBag)
        
        newOrderButton.bnd_slide.observeNext { [weak self] in
            self?.viewModel.checkAddressRequest.execute { resolver in
                if let location = try? resolver().first, location?.allowReg == true || location == nil {
                    if let strongSelf = self {
                        self?.viewModel.createQuickOrder(strongSelf)
                    }
                } else {
                    self?.handleError(LemonError.unavailableLocation)
                    self?.newOrderButton.bnd_mode.value = .defaultButton
                }
            }
        }.dispose(in: disposeBag)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        DataProvider.sharedInstance.pickupETA.bind(to: viewModel.pickupETA)
        
        viewModel.pickupETA.observeNext { [weak self] (value) in
            let date = Date().pickupShift(value)
            self?.nextPickupView.setTitle(date.timeHM(), subtitle: date.amPm())
        }.dispose(in: disposeBag)
        
        viewModel.userWalletBalance.observeNext { [weak self](amount) in
            var walletAmountHidden = true
            if let amount = amount {
                walletAmountHidden = !(amount > 0)
            }
            self?.walletView.isHidden = walletAmountHidden
            self?.walletViewBottomSeparator.isHidden = !walletAmountHidden
            self?.nextPickupViewContainer.backgroundColor = walletAmountHidden ? UIColor.lemonColor() : UIColor.clear
        }.dispose(in: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OrderListViewController.TokenAdded), name: notificationNameToken, object: nil)
    }
    
    @objc func TokenAdded() {
        viewModel.update()
    }
    
    @objc func phone() {
        if let phone = viewModel.phoneToCall {
            let alert = UIAlertController(title: "(914) 249-9534", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { _ in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(cancel)
            
            let call = UIAlertAction(title: "Call", style: UIAlertActionStyle.default) { _ in
                alert.dismiss(animated: true, completion: nil)
                UIApplication.shared.open(phone as URL, options: [:], completionHandler: nil)
            }
            alert.addAction(call)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    @objc func sendMessage() {
        if MFMessageComposeViewController.canSendText() {
            let messageController = MFMessageComposeViewController()
            messageController.recipients = [viewModel.phoneToText]
            messageController.messageComposeDelegate = self
            present(messageController, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.navigationController as? YellowNavigationController)?.barStyle.value = .yellow
        
        viewModel.update {
            self.tableView.reloadData()
            self.tableView.alpha = 1
            self.hintLabel.alpha = 1
        }
        
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.forsePickupETAUpdate), userInfo: nil, repeats: true)
        
        nextPickupView.startAnimation()
    }
    
    @objc fileprivate func forsePickupETAUpdate() {
        viewModel.pickupETA.next(viewModel.pickupETA.value)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
        
        nextPickupView.stopAnimation()
    }
    
    @IBAction func onReferralProgram(_ sender: UIBarButtonItem) {
        self.performSegueWithIdentifier(.ReferralProgram)
    }
    
    @IBAction func showMenu() {
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        viewModel.update { [weak refreshControl] in
            refreshControl?.endRefreshing()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier,
            let order = sender as? Order,
            let receiptScreen = segue.destination as? ReceiptViewController,
            StoryboardSegueIdentifier(rawValue: segueId) == .Receipt {
            
            receiptScreen.order = order
        } else if let viewController = segue.destination as? CommonContainerViewController {
            (self.navigationController as? YellowNavigationController)?.barStyle.value = .transparent
            if segue.identifier == StoryboardSegueIdentifier.Address.rawValue {
                viewController.viewModel = self.viewModel.commonAddressContainerViewModel
            } else {
                viewController.viewModel = self.viewModel.commonPaymentCardContainerViewModel
            }
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.tableView.alpha = 0
            self.hintLabel.alpha = 0
        }) 
    }
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return navigationController?.prefersStatusBarHidden ?? false
    }
}

extension OrderListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) as? OrderCell,
            let order = cell.viewModel?.order {
            
            if order.orderDetails != nil &&
                !order.orderDetails!.isEmpty &&
                !(order.status == .awaitingPickup || order.status == .pickedUp) {
                
                performSegueWithIdentifier(.Receipt, sender: order)
            } else if order.status == .awaitingPickup {
                router?.showEditOrderFlow(order)
            }
        }
    }
}

extension OrderListViewController : MGSwipeTableCellDelegate {
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        if direction == .leftToRight {
            return false
        }
        
        if let orderViewModel = (cell as? OrderCell)?.viewModel {
            return orderViewModel.canCancel || orderViewModel.canArchive
        }
        return cell is WalletTransitionCell
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, shouldHideSwipeOnTap point: CGPoint) -> Bool {
        if let viewModel = (cell as? OrderCell)?.viewModel {
            let order = viewModel.order
            if viewModel.canCancel {
                let _ = self.viewModel.cancelOrder(order, fromViewController: self)
            } else if viewModel.canArchive {
                self.viewModel.archiveOrder(order).execute { _ in }
            }
        } else if let transition = (cell as? WalletTransitionCell)?.viewModel?.walletTransition {
            self.viewModel.archiveWalletTransition(transition).execute { _ in }
        }

        return true
    }
}

extension OrderListViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        self.viewModel.tokenizeApplePay(payment, completion: completion)
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) { [weak self] in
            if let storngSelf = self, storngSelf.viewModel.quickOrder.value?.applePayToken != nil {
                self?.viewModel.createQuickOrder(storngSelf)
            } else {
                self?.newOrderButton?.bnd_mode.value = .defaultButton
            }
        }
    }
}


extension OrderListViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

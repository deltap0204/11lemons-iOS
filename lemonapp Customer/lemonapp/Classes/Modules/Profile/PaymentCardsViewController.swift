//
//  PaymentCardsViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond
import MGSwipeTableCell
import ReactiveKit

final class PaymentCardsViewModel: ViewModel {
    
    var paymentCellViewModels: MutableObservableArray<PaymentCellViewModel>
    var paymentCardCellViewModels: MutableObservableArray<PaymentCellViewModel>
    
    fileprivate let userWrapper: UserWrapper
    
    init (userWrapper: UserWrapper) {
        
        self.userWrapper = userWrapper
        
        paymentCardCellViewModels = MutableObservableArray(userWrapper.activePaymentCards.map { PaymentCardCellViewModel(paymentCard: $0, defaultPaymentCard: userWrapper.defaultPaymentCard) as PaymentCellViewModel })
        let groups = paymentCardCellViewModels
        
        if let applePayCard = userWrapper.applePayCard {
            groups.insert(ApplePayCardCellViewModel(applePayCard: applePayCard, defaultPaymentCard: self.userWrapper.defaultPaymentCard)  as PaymentCellViewModel, at: 0)
        }
        
        self.paymentCellViewModels = groups
        
        self.paymentCardCellViewModels.observeNext { [weak self] event in
            //switch event.operation {
            switch event.change {
            //case .remove(let range):
                case .deletes(let range):
                range.forEach {
                    var auxIndex = $0
                    if userWrapper.applePayCard != nil {
                        auxIndex = auxIndex - 1
                    }
                    if let paymentCard = self?.userWrapper.activePaymentCards[auxIndex] {
                        paymentCard.deleted = true
                        paymentCard.syncDataModel()
                    }
                }
                break;
            default:
                break;
            }
            self?.userWrapper.refresh()
        }
    }
    
    func reloadData() {
        //TODO migration-check
        
        //Before migration code
        //paymentCardCellViewModels.array = userWrapper.activePaymentCards.map { PaymentCardCellViewModel(paymentCard: $0, defaultPaymentCard: userWrapper.defaultPaymentCard) as PaymentCellViewModel }
        
        //Possible fix
        let auxArray = userWrapper.activePaymentCards.map { PaymentCardCellViewModel(paymentCard: $0, defaultPaymentCard: userWrapper.defaultPaymentCard) as PaymentCellViewModel }
        paymentCardCellViewModels.replace(with: auxArray)
        
        let groups = paymentCardCellViewModels
        
        if let applePayCard = userWrapper.applePayCard {
            groups.insert(ApplePayCardCellViewModel(applePayCard: applePayCard, defaultPaymentCard: self.userWrapper.defaultPaymentCard)  as PaymentCellViewModel, at: 0)
        }
        
        self.paymentCellViewModels = groups
        
    }
    
    func deletePaymentCard(_ paymentCard: PaymentCard) -> Action<() throws -> ()> {
        return Action {
            Signal { sink in
                _ = LemonAPI.deletePaymentCard(paymentCard: paymentCard)
                    .request().observeNext { (paymentCardResolver: EventResolver<Void>) in
                        do {
                            try paymentCardResolver()
                            sink.completed(with:{ })
                        } catch let error {
                            sink.completed(with:  { throw error } )
                        }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    func changeDefaultPaymentCard(_ paymentCard: PaymentCardProtocol) -> Action<() throws -> ()> {
        return Action { [weak self] in
            Signal { [weak self] sink in
                if let changedUser = self?.userWrapper.changedUser {
                    self?.userWrapper.defaultPaymentCard.value = paymentCard
                    _ = LemonAPI.editProfile(user: changedUser)
                        .request().observeNext { (userResolver: EventResolver<User>) in
                            do {
                                defer {
                                    self?.userWrapper.refresh()
                                }
                                try userResolver()
                                self?.userWrapper.saveChanges()
                                sink.completed(with: {})
                            } catch let error {
                                sink.completed(with:  { throw error } )
                            }
                    }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    
}

final class PaymentCardsViewController: UIViewController {
    
    @IBOutlet fileprivate weak var paymentCardsTable: UITableView!
    @IBOutlet fileprivate weak var goToProfileButton: LeftRightImageButton!
    @IBOutlet var goToProfileBtnHeight: NSLayoutConstraint!
    var prevCellIndexPath: IndexPath? = nil
    
    var viewModel: PaymentCardsViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: goToProfileBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: goToProfileButton)
        goToProfileButton.imagePosition = .left
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.paymentCardsTable.alpha = 1
        viewModel?.reloadData()
    }
    
    fileprivate func bindViewModel() {
        
        guard viewModel != nil && isViewLoaded else { return }
        
        viewModel?.paymentCellViewModels.bind(to: paymentCardsTable) { [weak self] dataSource,indexPath, tableView in
            if let paymentCardCellViewModel = dataSource/*[indexPath.section]*/[indexPath.row] as? PaymentCardCellViewModel {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCardCell", for: indexPath)
                if let paymentCardCell = cell as? PaymentCardCell {
                    paymentCardCell.viewModel = paymentCardCellViewModel
                    paymentCardCell.delegate = self
                    return paymentCardCell
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApplePayCardCell", for: indexPath)
                if let applePayCardCell = cell as? ApplePayCardCell,
                    let applePayCardCellViewModel = dataSource/*[indexPath.section]*/[indexPath.row] as? ApplePayCardCellViewModel {
                    applePayCardCell.viewModel = applePayCardCellViewModel
                    applePayCardCell.delegate = self
                    return applePayCardCell
                }
                return cell
            }
        }
    }
    
    @IBAction func addPaymentCard(_ sender: UIBarButtonItem) {
        performSegueWithIdentifier(.PaymentCard, sender: sender)
    }
    
    func showDeleteActionSheet(_ paymentCard: PaymentCard, indexPath: IndexPath) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            showLoadingOverlay()
            self?.viewModel?.deletePaymentCard(paymentCard).execute {
                do {
                    try $0()
                    self?.viewModel?.paymentCardCellViewModels.remove(at: indexPath.row)
                    AlertView().showInView(self?.navigationController?.parent?.view)
                } catch let error as BackendError {
                    self?.handleError(error)
                } catch let error {
                    print(error)
                }
                hideLoadingOverlay()
            }
        }
        actionSheet.addAction(deleteAction)
        let cancelAciton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAciton)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func changeDefaultPaymentCard(_ paymentCard: PaymentCardProtocol, indexPath: IndexPath) {
        showLoadingOverlay()
        viewModel?.changeDefaultPaymentCard(paymentCard).execute { [weak self] resolver in
            do {
                defer {
                    if let cell = self?.paymentCardsTable.cellForRow(at: indexPath) as? MGSwipeTableCell {
                        cell.hideSwipe(animated: true)
                    }
                    hideLoadingOverlay()
                }
                try resolver()
            } catch let error as ErrorWithDescriptionType {
                self?.handleError(error)
            } catch let error {
                print(error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let paymentCardDetailsVC = segue.destination as? PaymentCardDetailsViewController,
            let userWrapper = viewModel?.userWrapper {
            if let paymentCard = (sender as? PaymentCardCell)?.viewModel?.paymentCard {
                paymentCardDetailsVC.viewModel = PaymentCardDetailsViewModel(userWrapper: userWrapper, paymentCard: paymentCard)
            } else if sender is UIBarButtonItem {
                paymentCardDetailsVC.viewModel = PaymentCardDetailsViewModel(userWrapper: userWrapper)
            }
        }
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.paymentCardsTable.alpha = 0
        }) 
    }
}

extension PaymentCardsViewController: UITableViewDelegate, /*BNDTableViewProxyDataSource,*/ MGSwipeTableCellDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? MGSwipeTableCell {
            cell.showSwipe(.rightToLeft, animated: true)
        }
        // Removed editing ability
        //performSegueWithIdentifier(.PaymentCard, sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        if (direction == .rightToLeft) {
            return true
        }
        
        return false
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell!, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        NSLog("index = %d", index)
        switch index {
        case 0:
            if let indexPath = paymentCardsTable.indexPath(for: cell) {
                if let paymentCard = (cell as? PaymentCardCell)?.viewModel?.paymentCard {
                    changeDefaultPaymentCard(paymentCard, indexPath: indexPath)
                } else if let applePayCard = (cell as? ApplePayCardCell)?.viewModel?.applePayCard {
                    changeDefaultPaymentCard(applePayCard, indexPath: indexPath)
                }
            }
            break
        case 1:
            if let paymentCard = (cell as? PaymentCardCell)?.viewModel?.paymentCard,
                let indexPath = paymentCardsTable.indexPath(for: cell) {
                showDeleteActionSheet(paymentCard, indexPath: indexPath)
            }
            break
        default:
            break
        }
        
        return true
    }
    
}

//
//  AddressesViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond
import MGSwipeTableCell
import ReactiveKit

final class AddressesViewModel: ViewModel {
    
    let addressCellViewModels: MutableObservableArray<AddressCellViewModel>
    
    fileprivate let userWrapper: UserWrapper
    
    init (userWrapper: UserWrapper) {
        
        self.userWrapper = userWrapper
        let addressCellViewModels = userWrapper.activeAddresses.map { AddressCellViewModel(address: $0, defaultAddress: userWrapper.defaultAddress) }
        self.addressCellViewModels = MutableObservableArray<AddressCellViewModel>(addressCellViewModels)
        self.addressCellViewModels.observeNext { [weak self] event in
            /*
            switch event.operation {
            case .remove(let range):
                range.forEach {
                    if let address = self?.userWrapper.activeAddresses[$0] {
                        address.deleted = true
                        address.syncDataModel()
                    }
                }
                break;
            default:
                break;
            }*/
            switch event.change {
            case .deletes(let range):
                range.forEach {
                    if let address = self?.userWrapper.activeAddresses[$0] {
                        address.deleted = true
                        DataProvider.sharedInstance.saveAddressInDB(address: address)
                        _ = LemonAPI.deleteAddress(address: address)
                            .request().observeNext { (addressResolver: @escaping EventResolver<Void>) in
                                
                        }
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
        //self.addressCellViewModels.array = userWrapper.activeAddresses.map { AddressCellViewModel(address: $0, defaultAddress: userWrapper.defaultAddress) }
        
        //Possible fix
        let replaceArray = userWrapper.activeAddresses.map { AddressCellViewModel(address: $0, defaultAddress: userWrapper.defaultAddress) }
        self.addressCellViewModels.replace(with: replaceArray)
        
    }
    
    func deleteAddress(_ address: Address) -> Action<() throws -> ()> {
        return Action {
            Signal { sink in
                _ = LemonAPI.deleteAddress(address: address)
                    .request().observeNext { [weak self] (addressResolver: @escaping EventResolver<Void>) in
                        do {
                            try addressResolver()
                            if let addressIndex = self?.userWrapper.activeAddresses.index(of: address) {
                                self?.addressCellViewModels.remove(at: addressIndex)
                            }
                            sink.completed(with: {
                                return try addressResolver()
                            })
                        } catch let error {
                            sink.completed(with:  { throw error } )
                        }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    func changeDefaultAddress(_ address: Address) -> Action<() throws -> ()> {
        return Action { [weak self] in
            Signal { [weak self] sink in
                if let changedUser = self?.userWrapper.changedUser {
                    self?.userWrapper.defaultAddress.value = address
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

final class AddressesViewController: UIViewController {
    
    @IBOutlet fileprivate weak var addressesTable: UITableView!
    @IBOutlet fileprivate weak var goToProfileButton: LeftRightImageButton!
    
    var prevCellIndexPath: IndexPath? = nil
    @IBOutlet var goToProfileBtnHeight: NSLayoutConstraint!
    
    var viewModel: AddressesViewModel? {
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
        self.addressesTable.alpha = 1
        viewModel?.reloadData()
    }
    
    fileprivate func bindViewModel() {
        
        guard viewModel != nil && isViewLoaded else { return }
        //TODO migration-check
        //TODO tableview-migration
        //Before migration code
        //viewModel?.addressCellViewModels.bind(to: addressesTable, proxyDataSource: self, createCell: { [weak self] (dataSource, indexPath, tableView) -> UITableViewCell in
        
        //Possible fix
        viewModel?.addressCellViewModels.bind(to: addressesTable, animated: true, rowAnimation: UITableViewRowAnimation.automatic, createCell: { (dataSource, indexPath, tableView) -> UITableViewCell in
           let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath)
            if let addressCell = cell as? AddressCell {
                addressCell.viewModel = dataSource/*[indexPath.section]*/[indexPath.row]
                addressCell.delegate = self
                return addressCell
            }
            return cell
        })
    }
    
    @IBAction func addAddress(_ sender: UIBarButtonItem) {
        performSegueWithIdentifier(.Address, sender: sender)
    }
    
    func showDeleteActionSheet(_ address: Address) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            showLoadingOverlay()
            self?.viewModel?.deleteAddress(address).execute { [weak self] in
                do {
                    try $0()
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
    
    func changeDefaultAddress(_ address: Address, indexPath: IndexPath) {
        showLoadingOverlay()
        viewModel?.changeDefaultAddress(address).execute { [weak self] resolver in
            do {
                defer {
                    if let cell = self?.addressesTable.cellForRow(at: indexPath) as? MGSwipeTableCell {
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
        
        if let addressDetailsVC = segue.destination as? AddressDetailsViewController,
        let userWrapper = viewModel?.userWrapper {
            if let address = (sender as? AddressCell)?.viewModel?.address {
                addressDetailsVC.viewModel = AddressDetailsViewModel(userWrapper: userWrapper, address: address)
            } else if sender is UIBarButtonItem {
                addressDetailsVC.viewModel = AddressDetailsViewModel(userWrapper: userWrapper)
            }
        }
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.addressesTable.alpha = 0
        }) 
    }
}

extension AddressesViewController: UITableViewDelegate/*, BNDTableViewProxyDataSource*/, MGSwipeTableCellDelegate {
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) as? MGSwipeTableCell {
            cell.showSwipe(.rightToLeft, animated: true)
        }
        // Removed editing ability
//        performSegueWithIdentifier(.Address, sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        if direction == .rightToLeft {
            return true
        }
        
        return false
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell!, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        if let address = (cell as? AddressCell)?.viewModel?.address {
            switch index {
            case 1:
                showDeleteActionSheet(address)
                break
            default:
                if let indexPath = addressesTable.indexPath(for: cell) {
                    changeDefaultAddress(address, indexPath: indexPath)
                }
                break
            }
        }
        return true
    }
    
}


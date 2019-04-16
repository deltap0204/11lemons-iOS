//
//  ProductViewController.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/4/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import MGSwipeTableCell

final class ProductViewController: UIViewController {
    
    @IBOutlet fileprivate weak var productsTable: UITableView!
    @IBOutlet fileprivate weak var changesDoneButton: UIButton!
    
    @IBOutlet fileprivate weak var editBtn: UIBarButtonItem!    
    @IBOutlet fileprivate weak var menuBtn: UIBarButtonItem!
    @IBOutlet var cancelBtn: UIBarButtonItem!
    @IBOutlet fileprivate weak var doneBtn: UIBarButtonItem!
    
    @IBOutlet fileprivate weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var doneBtnHeight: NSLayoutConstraint!
    
    var router: ProductRouter?
    
    var viewModel = ProductViewModel()
    var firstLoad = true
    
    fileprivate lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ProductViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: doneBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: changesDoneButton)
        productsTable.addSubview(self.refreshControl)
        firstLoad = true
        bindViewModel()
        changesDoneButton.bnd_tap.observeNext { [weak self] in
            guard let selfM = self else { return }
            if selfM.viewModel.isEditionMode.value {
                selfM.router?.showNewDepartmentFlow(selfM)
            } else {
                selfM.router?.showOrdersFlow()
            }
        }
        self.viewModel.delegate = self
        self.changesDoneButton.setTitle("Done")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.navigationController as? YellowNavigationController)?.barStyle.value = .blue
        self.productsTable.alpha = 1
        if !firstLoad {
            self.viewModel.updateDepartmentList({})
        } else {
            firstLoad = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (self.navigationController as? YellowNavigationController)?.barStyle.value = .yellow
        if viewModel.isEditionMode.value {
            self.viewModel.isEditionMode.value = false
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.productsTable.alpha = 0
        }) 
    }
    
    fileprivate func bindViewModel() {
        
        guard isViewLoaded else { return }
        
        viewModel.isEditionMode.observeNext { [weak self] isEditionMode in
            if isEditionMode {
                self?.navigationItem.rightBarButtonItems = [self!.doneBtn]
                self?.navigationItem.leftBarButtonItems = [self!.cancelBtn]
                self?.animateDoneButtonToAdd()
                self?.tableViewBottomConstraint.constant = 0
            } else {
                
                self?.navigationItem.rightBarButtonItems = [self!.editBtn]
                self?.navigationItem.leftBarButtonItems = [self!.menuBtn]
                self?.animateAddButtonToDone()
                self?.tableViewBottomConstraint.constant = self?.changesDoneButton.frame.height ?? 0
            }
        }
        
        viewModel.productCellViewModels.bind(to: productsTable) { dataSource, indexPath, tableView in
            let cell = tableView.dequeueReusableCell(withIdentifier: ProductAdminCell.Identifier, for: indexPath)
            //TODO migration-check
            //TODO tableview-migration
            //Before migration code
            if let productCell = cell as? ProductAdminCell {
                productCell.viewModel = dataSource/*[indexPath.section]*/[indexPath.row]
                productCell.delegate = self
                return productCell
            }
            return cell
        }
    }
    
    fileprivate func animateAddButtonToDone() {
        UIView.animate(withDuration: 0.6,
                                   animations: {
            self.changesDoneButton.alpha = 1
        })
    }
    
    fileprivate func animateDoneButtonToAdd() {
        UIView.animate(withDuration: 0.6,
                                   animations: {
            self.changesDoneButton.alpha = 0
        })
    }
    
    @IBAction func openMenu(_ sender: UIBarButtonItem) {
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let subproductsVC = segue.destination as? SubproductsAdminViewController,
            let subproductsAdminViewModel = (sender as? ProductAdminCell)?.viewModel?.subprodutsViewModel {
            subproductsVC.viewModel = subproductsAdminViewModel
            subproductsVC.router = self.router
        }
    }
   
    @IBAction func onEditAction(_ sender: UIBarButtonItem) {
        self.viewModel.isEditionMode.value = true
        self.viewModel.saveList()
        
    }
    
    @IBAction func onDoneAction(_ sender: UIBarButtonItem) {
        self.viewModel.updateChanges()
        self.viewModel.isEditionMode.value = false
    }
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        self.viewModel.restoreList()
        self.viewModel.isEditionMode.value = false
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        viewModel.updateDepartmentList { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
}

extension ProductViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !viewModel.isEditionMode.value {
            if viewModel.productCellViewModels[indexPath.row].subprodutsViewModel != nil {
                performSegueWithIdentifier(.Subproducts, sender: tableView.cellForRow(at: indexPath))
            }
        } else {
            if let cellVM: ProductAdminCellViewModel = viewModel.productCellViewModels[indexPath.row] {
                self.router?.showEditServiceCategoryFlow(self, departmentToEdit: cellVM.service)
            }
        }
    }
}

extension ProductViewController: ProductViewModelDelegate {
    func navigateToProductDetail(_ serviceCategory: Service) {
        self.router?.showEditServiceCategoryFlow(self, departmentToEdit: serviceCategory)
    }
}

extension ProductViewController: MGSwipeTableCellDelegate {
    
    
    func swipeTableCell(_ cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        if direction == .leftToRight {
            return false
        }
        return true
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell!, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        guard let viewModelCell = (cell as? ProductAdminCell)?.viewModel else {
            return true
        }
        
        switch index {
        case 0:
            self.router?.showEditServiceCategoryFlow(self, departmentToEdit: viewModelCell.service)
            break
        default:
            break
        }
        return true
    }
}

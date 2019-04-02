//
//  PricingViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond


final class PricingViewController: UIViewController {
    
    @IBOutlet fileprivate weak var productsTable: UITableView!
    @IBOutlet fileprivate weak var newOrderButton: UIButton!
    
    @IBOutlet var doneBtnHeight: NSLayoutConstraint!
    
    var router: PricingRouter?
    
    var viewModel = PricingViewModel()
    
    fileprivate lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PricingViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: doneBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: newOrderButton)
        productsTable.addSubview(self.refreshControl)
        
        bindViewModel()
        self.viewModel.delegate = self
        
        newOrderButton.bnd_tap.observeNext { [weak self] in
            self?.router?.showOrdersFlow()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.productsTable.alpha = 1
        self.viewModel.updateDepartmentList({})
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.2, animations: {
            self.productsTable.alpha = 0
        }) 
    }
    
    fileprivate func bindViewModel() {
        
        guard isViewLoaded else { return }
        
        viewModel.productCellViewModels.bind(to: productsTable) { dataSource, indexPath, tableView in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
            //TODO migration-check
            //TODO tableview-migration
            //Before migration code
            
            if let productCell = cell as? ProductCell {
                productCell.viewModel = dataSource[indexPath.row]
                return productCell
            }
 
            cell.selectionStyle = .none
            return cell
        }
    }
    
    @IBAction func openMenu(_ sender: UIBarButtonItem) {
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let subproductsVC = segue.destination as? SubproductsViewController,
        let subproductsViewModel = (sender as? ProductCell)?.viewModel?.subprodutsViewModel {
            subproductsVC.viewModel = subproductsViewModel
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        viewModel.updateDepartmentList { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
}


extension PricingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if viewModel.productCellViewModels[indexPath.row].subprodutsViewModel != nil {
            performSegueWithIdentifier(.Subproducts, sender: tableView.cellForRow(at: indexPath))
        }
    }
}

extension PricingViewController: ProductViewModelDelegate {
    
    func hiddenLoading() {
        self.refreshControl.endRefreshing()
    }
}

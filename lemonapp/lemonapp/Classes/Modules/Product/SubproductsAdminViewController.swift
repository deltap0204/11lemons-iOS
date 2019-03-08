//
//  SubproductsAdminViewController.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/31/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import UIKit
import Bond
import MGSwipeTableCell
import MBProgressHUD

final class SubproductsAdminViewController: UIViewController {
    
    @IBOutlet fileprivate weak var subproductsTable: UITableView!
    @IBOutlet fileprivate weak var backButton: LeftRightImageButton!
    @IBOutlet var backBtnHeight: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var addButton: UIBarButtonItem!
    var router: ProductRouter?
    var fisrtTime = true
    
    var viewModel: SubproductsAdminViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: backBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: backButton)
        fisrtTime = true
        backButton.imagePosition = .left
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.navigationController as? YellowNavigationController)?.barStyle.value = .blue
        if fisrtTime { fisrtTime = false
        } else { viewModel!.updateServices() }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (self.navigationController as? YellowNavigationController)?.barStyle.value = .yellow
    }
    
    fileprivate func bindViewModel() {
        guard viewModel != nil && isViewLoaded else { return }
        
        viewModel!.delegate = self
        viewModel?.subproductCellViewModels.bind(to: subproductsTable) { dataSource, indexPath, tableView in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubproductAdminCell", for: indexPath)
            //TODO migration-check
            //TODO tableview-migration
            //Before migration code
            
            if let productCell = cell as? SubproductAdminCell {
                productCell.viewModel = dataSource/*[indexPath.section]*/[indexPath.row]
                productCell.delegate = self
                return productCell
            }
 
 
            return cell
        }
        
        viewModel?.isBusy.observeNext {[weak self] isBusy in
            guard let strongSelf = self else { return }

            if isBusy {
                MBProgressHUD.showAdded(to: strongSelf.view, animated: true)
            } else {
                MBProgressHUD.hide(for: strongSelf.view, animated: true)
            }
        }
        self.title = viewModel?.title
    }
    
    @IBAction func onAdd(_ sender: AnyObject) {
        router?.showNewServiceFlow(self, department: self.viewModel!.department)
    }

    fileprivate func showDeleteConfirmation(_ service: Service) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete Service", style: .destructive, handler: { _ in
            self.viewModel!.deleteService(service)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension SubproductsAdminViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.router?.showEditServiceFlow(self, serviceToEdit: self.viewModel!.getServiceByPosition(indexPath.row), department: self.viewModel!.department)
    }
}

extension SubproductsAdminViewController: SubproductViewModelDelegate {
    func navigateToProductDetail(_ service: Service, department: Service) {
        self.router?.showEditServiceFlow(self, serviceToEdit: service, department: department)
    }
    
    func goBackSuccefully() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .customView
        let image = UIImage(named: "ShapeCheck")
        hud.customView = UIImageView(image: image)
        hud.isSquare = true
        hud.label.text = NSLocalizedString("Done", tableName: nil, comment: "HUD done title")

        hud.hide(animated: true, afterDelay: 1.0)
    }
}

extension SubproductsAdminViewController: MGSwipeTableCellDelegate {
    
    
    func swipeTableCell(_ cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        if direction == .leftToRight {
            return false
        }
        return true
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell!, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        guard let viewModelCell = (cell as? SubproductAdminCell)?.viewModel else {
            return true
        }
        
        switch index {
        case 0:
            self.showDeleteConfirmation(viewModelCell.service)
            break
        case 1:
            self.router?.showEditServiceFlow(self, serviceToEdit: viewModelCell.service, department: self.viewModel!.department)
            break
            default:
                break
        }
        return true
    }
}

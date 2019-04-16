//
//  ServiceSelectionViewController.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/31/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import UIKit
import Bond
import MGSwipeTableCell

final class ServiceSelectionViewController: UIViewController {
    
    @IBOutlet fileprivate weak var subproductsTable: UITableView!
    @IBOutlet fileprivate weak var backButton: LeftRightImageButton!
    
    @IBOutlet fileprivate weak var btnBarBack: UIBarButtonItem!
    var viewModel: ServiceSelectionViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.imagePosition = .left
        navigationItem.leftBarButtonItems = [btnBarBack]
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.navigationController as? YellowNavigationController)?.barStyle.value = .blue
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (self.navigationController as? YellowNavigationController)?.barStyle.value = .yellow
    }
    
    fileprivate func bindViewModel() {
        guard viewModel != nil && isViewLoaded else { return }
        
        viewModel?.subproductCellViewModels.bind(to: subproductsTable) { dataSource, indexPath, tableView in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceSelectionCell", for: indexPath)
            if let productCell = cell as? ServiceSelectionCell {
                //TODO migration-check
                //TODO tableview-migration
                //Before migration code
                
                productCell.viewModel = dataSource/*[indexPath.section]*/[indexPath.row]
                return productCell
            }
            return cell
        }
        
        self.title = viewModel?.title
    }
    @IBAction func onNavigationBack(_ sender: AnyObject) {
        guard let viewModel = viewModel else { return }
        viewModel.submitChanges()
        self.navigationController?.popViewController(animated: true)
    }
}

extension ServiceSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let viewModel = viewModel else { return }
        viewModel.selectedService(indexPath.row)
     
    }
}

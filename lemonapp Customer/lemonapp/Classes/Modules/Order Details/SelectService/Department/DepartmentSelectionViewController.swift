//
//  DepartmentSelectionViewController.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/4/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation

final class DepartmentSelectionViewController: UIViewController {
    
    @IBOutlet fileprivate weak var productsTable: UITableView!
    
    var viewModel: DepartmentSelectionViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        guard isViewLoaded else { return }
        guard let viewModel = viewModel else { return }
        
        viewModel.departmentCellViewModels.bind(to: productsTable) { dataSource, indexPath, tableView in
            let cell = tableView.dequeueReusableCell(withIdentifier: DepartmentSelectionCell.Identifier, for: indexPath)
            
            //TODO migration-check
            //TODO tableview-migration
            //Before migration code
            
            if let productCell = cell as? DepartmentSelectionCell {
                productCell.viewModel = dataSource/*[indexPath.section]*/[indexPath.row]
                return productCell
            }
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let servicesVC = segue.destination as? ServiceSelectionViewController {
            guard let viewModel = viewModel else { return }
            servicesVC.viewModel = ServiceSelectionViewModel(department: viewModel.departmentSelected!, selectionDelegate: viewModel)
        }
    }
    
    //MARK: Actions
    @IBAction func onDone(_ sender: AnyObject) {
        guard let viewModel = viewModel else { return }
        viewModel.done()
    }
    
    @IBAction func onCancel(_ sender: AnyObject) {
        guard let viewModel = viewModel else { return }
        viewModel.cancel()
    }

    @IBAction func onSelectAll(_ sender: AnyObject) {
        guard let viewModel = viewModel else { return }
        viewModel.selectAll()
    }
    
    @IBAction func onClearAll(_ sender: AnyObject) {
        guard let viewModel = viewModel else { return }
        viewModel.clearSelections()
    }
}

extension DepartmentSelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let viewModel = viewModel else { return }
        viewModel.departmentSelected(indexPath.row)
    }
}

extension DepartmentSelectionViewController: DepartmentSelectionViewModelDelegate {
    func segue(_ name: String) {
        performSegue(withIdentifier: name, sender: nil)
    }
    
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

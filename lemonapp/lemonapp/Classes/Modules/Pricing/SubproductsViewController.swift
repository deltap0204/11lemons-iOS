//
//  SubproductsViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond

final class SubproductsViewModel: ViewModel {
    
    let subproductCellViewModels: ObservableArray<SubproductCellViewModel>
    let title: String
    
    fileprivate let department: Service
    
    init(department: Service) {
        self.department = department
        self.title = department.name
        if let services = department.typesOfService {
        self.subproductCellViewModels = ObservableArray(services.flatMap { $0.active ? SubproductCellViewModel(service: $0) : nil })
        } else {
            self.subproductCellViewModels = ObservableArray([])
        }
    }
}

final class SubproductsViewController: UIViewController {
    
    @IBOutlet fileprivate weak var subproductsTable: UITableView!
    @IBOutlet fileprivate weak var backButton: LeftRightImageButton!
    
    @IBOutlet var backBtnHeight: NSLayoutConstraint!
    
    var viewModel: SubproductsViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.imagePosition = .left
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: backBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: backButton)
        
        bindViewModel()
    }
    
    fileprivate func bindViewModel() {
        
        guard viewModel != nil && isViewLoaded else { return }
        
        viewModel?.subproductCellViewModels.bind(to: subproductsTable) { dataSource, indexPath, tableView in
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubproductCell", for: indexPath)
            if let productCell = cell as? SubproductCell {
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
    
}
extension SubproductsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

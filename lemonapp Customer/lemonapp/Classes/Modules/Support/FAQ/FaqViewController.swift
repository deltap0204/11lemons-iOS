//
//  FaqViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit


final class FaqViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var backButton: UIButton!

    @IBOutlet var backBtnHeight: NSLayoutConstraint!
    
    
    fileprivate lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FaqViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    
    fileprivate let viewModel = FaqViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: backBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: backButton)
        tableView.addSubview(self.refreshControl)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.fixBackArrow()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 63
        
        bindViewModel(viewModel)
    }
    
    func bindViewModel(_ viewModel: FaqViewModel) {
        viewModel.faqViewModels.bind(to: tableView) { dataSource, indexPath, tableView in
            //TODO migration-check
            //TODO tableview-migration
            //Before migration code
            
            let faqViewModel = dataSource/*[indexPath.section]*/[indexPath.row]
            if faqViewModel.shouldShowAnswer {
                let cell = tableView.dequeueReusableCell(withIdentifier: AnswerCell.CellId, for: indexPath) as! AnswerCell
                cell.viewModel = faqViewModel
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: QuestionCell.CellId, for: indexPath) as! QuestionCell
            cell.viewModel = faqViewModel
            return cell

            
        }
 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.toggleFaqAtIndexPath(indexPath)
        tableView.reloadData()
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        viewModel.update { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
}

//
//  MenuViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond
import DrawerController


final class MenuViewController : UIViewController {
    
    fileprivate let viewModel = MenuViewModel()
    var router: MenuRouter!
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var signOutButton: UIButton!
    @IBOutlet weak var menuHeaderView: MenuHeaderView!
    @IBOutlet fileprivate weak var adminModeSwitch: UISwitch!
    @IBOutlet var signoutBottomSpace: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: signoutBottomSpace, baseValue: 0)

        tableView.register(MenuItemCell.nib()!, forCellReuseIdentifier: "Cell")
        
        viewModel.menuItems.bind(to: tableView) {
            dataSource, indexPath, tableView in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            //TODO migration-check
            //TODO tableview-migration
            //Before migration code
            
            if let cell = cell as? MenuItemCell {
                //cell.menuItem = dataSource[indexPath.section][indexPath.row]
                cell.menuItem = dataSource[indexPath.row]
            }
            return cell
        }
        
        router.selectedMenuItem.bidirectionalBind(to: viewModel.selectedMenuItem)
        
        viewModel.isAdminModeSwitcherHidden.bind(to: adminModeSwitch.bnd_hidden)
        adminModeSwitch.isOn = DataProvider.sharedInstance.isAdminUser()
        adminModeSwitch.bnd_on.bind(to: viewModel.isAdminMode)
        
        viewModel.isAdminMode.observeNext(with: { [weak self] in
            self?.menuHeaderView.adminLabel.isHidden = !$0
            self?.menuHeaderView.balanceLabel.isHidden = $0
            self?.menuHeaderView.balanceButton.isHidden = $0
        })
        
        tableView.selectRow(at: IndexPath(row: viewModel.indexOfSelectedItem(), section: 0), animated: false, scrollPosition: .none)
        
        signOutButton.bnd_tap.observeNext { [weak self] in
            
            let signOutAlert = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
            signOutAlert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            signOutAlert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
                if let source = self,
                    let destination = UIStoryboard(storyboard: .Auth).instantiateInitialViewController() {
                    ReplaceSegue(identifier: nil, source: source, destination: destination).perform()
                    DataProvider.sharedInstance.clear()
                    LemonCoreDataManager.dropDataBase()
                    LemonAPI.clear()
                }
                })
            self?.present(signOutAlert, animated: true, completion: nil)
        }
        
    
        viewModel.menuHeaderViewModel.observeNext { [weak menuHeaderView] in
            menuHeaderView?.viewModel = $0
        }
        menuHeaderView.bnd_tap.observeNext { [weak self] in
            //TODO migration-check
            //TODO tableview-migration
            //Before migration code
            if let strongSelf = self,
                let index = strongSelf.viewModel.menuItems.array.index(of: strongSelf.viewModel.selectedMenuItem.value) {
                    strongSelf.tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: false)
            }
            self?.viewModel.selectMenuItem(.Profile)
        }
        viewModel.selectedMenuItem.observeNext { [weak menuHeaderView] in
            menuHeaderView?.selected = $0 == .Profile            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //TODO migration-check
        //TODO tableview-migration
        //Before migration code
        
        if let index = viewModel.menuItems.array.index(of: viewModel.selectedMenuItem.value) {
            tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
        } else if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRowIndexPath, animated:false)
            menuHeaderView?.selected = viewModel.selectedMenuItem.value == .Profile
        }

    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return router?.statusBarStyle.value ?? .default
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return .none
    }
}


extension MenuViewController: UITableViewDelegate {
    
    //func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuItem = viewModel.menuItems.array[indexPath.row]
        if DataProvider.sharedInstance.cloudCloset.count <= 0 && menuItem == .CloudCloset {
            parent?.showAlert("Your Closet is empty",
                message: "After you place an order, you'll find\nall your clothes neatly organized\n here in your CloudCloset",
                positiveButton: "OK",
                positiveAction: { [weak self] _ in
                    if let strongSelf = self {
                        strongSelf.tableView.selectRow(at: IndexPath(row: strongSelf.viewModel.indexOfSelectedItem(), section: 0), animated: false, scrollPosition: .none)
                    }
            })
        } else {
            viewModel.selectMenuItem(menuItem)
        }
    }
}


extension MenuViewController {
    
    class func fromNib() -> MenuViewController {
        return MenuViewController(nibName: classNameFromClass(self), bundle: nil)
    }
}

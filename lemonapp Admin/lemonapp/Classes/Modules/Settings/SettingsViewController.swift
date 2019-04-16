//
//  SettingsViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond
import DrawerController
import SnapKit
import ReactiveKit
import SwiftyJSON


class SettingsCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var btnAccessor: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblTitle.font = UIFont.systemFont(ofSize: 15)
        self.lblSubTitle.font = UIFont.systemFont(ofSize: 15)
    }
}

final class SettingsViewController: UIViewController {
    @IBOutlet weak var tblView: UITableView!

    var router: MenuRouter!
    
    let settingArr = [["title":"","description":"Notification","RushService":""],["title":"CUSTOMER SERVICE","description":"Contact Information","RushService":""],["title":"BUSINESS INFORMATION","description":"Hours of Opration","RushService":"Rush Services can  be  customized in the Hours of Opration Section"]]
    
//    let section = ["", "CUSTOMER SERVICE", "BUSINESS INFORMATION"]
//    let items = [["Notification"], ["Contact Information"], ["Hours of Opration", "Rush Services can  be  customized in the Hours of Opration Section"]]
//
//    //@IBOutlet fileprivate weak var cloudClosetSwitch: UISwitch!
   // @IBOutlet fileprivate weak var pushButton: UIButton!
   // @IBOutlet fileprivate weak var emailButton: UIButton!
   // @IBOutlet fileprivate weak var messageButton: UIButton!
   // @IBOutlet var circularButtons: [UIButton]!
   // @IBOutlet var cloudClosetIconView: UIImageView!
    
    @IBOutlet var doneBtn: HighlightedButton!
    @IBOutlet var doneBtnHeight: NSLayoutConstraint!
   
    var viewModel: SettingsViewModel? {
        didSet {
            if let viewModel = viewModel {
                bindViewModel(viewModel)
               
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.reloadData()



        //circularButtons.forEach { $0.centerImageAndTitle() }
        
        
        if let viewModel = viewModel {
            bindViewModel(viewModel)
          
           
        }
        
       // cloudClosetIconView.tintColor = UIColor.white
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.alpha = 1
        viewModel?.refresh()
    }
    
    
    @IBAction func save(_ sender: AnyObject?) {
        if let viewModel = viewModel {
            viewModel.saveRequest.execute { [weak self] resolver in
                do {
                    try resolver()
                } catch let error as BackendError {
                    self?.handleError(error)
                } catch let error {
                    print(error)
                }
            }
            viewModel.goToOrders()
        }
    }

    
    
    func bindViewModel(_ viewModel: SettingsViewModel) {
        guard isViewLoaded else { return }
        
        
        
//        viewModel.cloudClosetEnabled.bidirectionalBind(to: cloudClosetSwitch.bnd_on)
//
//        viewModel.mailSelected.bind(to: emailButton.bnd_selected)
//        viewModel.mailEnabled.bidirectionalBind(to: viewModel.mailSelected)
//
//        viewModel.pushSelected.bind(to: pushButton.bnd_selected)
//        viewModel.pushEnabled.bidirectionalBind(to: viewModel.pushSelected)
//
//        viewModel.messageSelected.bind(to: messageButton.bnd_selected)
//        viewModel.messageEnabled.bidirectionalBind(to: viewModel.messageSelected)
//
//
//        emailButton.bnd_tap.observeNext { [weak self] result in
//            guard let strongSelf = self else { return }
//            strongSelf.emailButton.isSelected = !strongSelf.emailButton.isSelected
//            viewModel.mailSelected.next(strongSelf.emailButton.isSelected)
//        }
//        pushButton.bnd_tap.observeNext { [weak self] result in
//            guard let strongSelf = self else { return }
//            strongSelf.pushButton.isSelected = !strongSelf.pushButton.isSelected
//            viewModel.pushSelected.next(strongSelf.pushButton.isSelected)
//        }
//        messageButton.bnd_tap.observeNext { [weak self] result in
//            guard let strongSelf = self else { return }
//            strongSelf.messageButton.isSelected = !strongSelf.messageButton.isSelected
//            viewModel.messageSelected.next(strongSelf.messageButton.isSelected)
//        }
    }
    
    
    @IBAction func showMenu() {
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
   
    
    
    
    
    
}
extension SettingsViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewTitle = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:44))
        let lblTitle = UILabel(frame: CGRect(x:15, y:10, width:tableView.frame.size.width-30, height:30))
        lblTitle.font = UIFont.systemFont(ofSize: 14)
        if section == 1 {
            lblTitle.text = String("Customer Service").uppercased()
        }else if section == 2 {
            lblTitle.text = String("Business Information").uppercased()
        }else {
            lblTitle.text = ""
        }
        viewTitle.addSubview(lblTitle)
        return viewTitle
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SettingsCell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath) as? SettingsCell ?? SettingsCell()
        
        cell.lblTitle.text = ""
        cell.lblSubTitle.text = ""
        
        if indexPath.section == 0 {
            cell.lblTitle.text = String("Notification")
            cell.lblSubTitle.text = "Push, SMS"
        }else if indexPath.section == 1 {
            cell.lblTitle.text = String("Contact Information")
        }else if indexPath.section == 2 {
            cell.lblTitle.text = "Hours of Operation"
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let vc:NotificationStyleViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: NotificationStyleViewController.self)) as? NotificationStyleViewController ?? NotificationStyleViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.section == 1 {
            let vc:ContactInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ContactInfoViewController.self)) as? ContactInfoViewController ?? ContactInfoViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.section == 2 {
            let vc:OperationsViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: OperationsViewController.self)) as? OperationsViewController ?? OperationsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

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
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubTitle: UILabel!
    @IBOutlet weak var btnAccessor: UIButton!
    @IBOutlet weak var txtFieldTitle: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblTitle.font = UIFont.systemFont(ofSize: 15)
        if let _ = self.lblSubTitle {
            self.lblSubTitle.font = UIFont.systemFont(ofSize: 15)            
        }
    }
}

final class SettingsViewController: UIViewController {
    @IBOutlet weak var tblView: UITableView!
    var router: MenuRouter!
    
    var dictSettings:[String:Any] = [:]
    var dictHoursOperation:[String:Any] = [:]
    
    let settingArr = [["title":"","description":"Notification","RushService":""],["title":"CUSTOMER SERVICE","description":"Contact Information","RushService":""],["title":"BUSINESS INFORMATION","description":"Hours of Opration","RushService":"Rush Services can  be  customized in the Hours of Opration Section"]]

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
      //  getHoursOperation()
        if let viewModel = viewModel {
            bindViewModel(viewModel)
            
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.alpha = 1
        getNotificationSetting()

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
    }
    
    
    @IBAction func showMenu() {
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    func getNotificationSetting(){
        if let url = URL(string: String(format: "%@/GetNotificationAndContactInfoSetting", Config.LemonEndpoints.APIEndpoint.rawValue)) {
            DispatchQueue.main.async {
                showLoadingOverlay()
            }

            var headers: [String:String]? = nil
            if let accessToken = LemonAPI.accessToken?.value,
                let userId = LemonAPI.userId {
                headers = [
                    "Authorization": "Bearer \(accessToken)",
                    LemonAPI.USER_ID_HEADER: "\(userId)"
                ]
                  print("accessToken",accessToken)
            }
//            headers = [
//                "Authorization": "bearer YZnmUgR0Xr7eG9Ghnwi-EFYm8Sa93uhn-fE2Z0aWJ-7cIUYemU9XFvXsXaI5l107vbTucN2_PPqYFR6tL115U5WeFvpsLs59UFd3BKX7WYTyVaKvyDbB5VTAaONjKqlEpVEj2ik-HyuSgV8BD-We7wNeYM0sYHtmDR4LGMbcBdRcSbr0r_p9Yfhx-Z85luVcuV8chn6B9pJSH18nXGKF8KH0iqr5fi03MoRgVFfgvMwyr3f1l7ty4R5rnvHczAte",
//                LemonAPI.USER_ID_HEADER: "1070"
//            ]
            
            var request = URLRequest(url: url)
            request.allHTTPHeaderFields = headers
            
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    hideLoadingOverlay()
                }
                

                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print("responsenotificationSettingJSON",responseJSON)
                    self.dictSettings = responseJSON
                }
            }
            task.resume()
        }
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
            vc.dictNotificationSettings = self.dictSettings
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.section == 1 {
            let vc:ContactInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ContactInfoViewController.self)) as? ContactInfoViewController ?? ContactInfoViewController()
            vc.dictContactInfo = self.dictSettings
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.section == 2 {
            let vc:OperationsViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: OperationsViewController.self)) as? OperationsViewController ?? OperationsViewController()
              vc.dictHours = self.dictHoursOperation
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

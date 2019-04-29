//
//  NotificationStyleViewController.swift
//  DemoTableView
//
//  Created by Apple on 13/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit
import SwiftyJSON

final class NotificationStyleViewModel: ViewModel {
    let isEmail: Observable<Bool?> = Observable(UserDefaults.standard.bool(forKey: ""))
    let isSMS: Observable<Bool?> = Observable(UserDefaults.standard.bool(forKey: ""))
    let isNotification: Observable<Bool?> = Observable(UserDefaults.standard.bool(forKey: ""))
    
    func storeLatestEmail() {
//        if let email = self.email.value, email.isEmail {
//            let ud = UserDefaults.standard
//            ud.setValue(email, forKey: NSUserDefaultsDataKeys.LatestEmailAddress.rawValue)
//            ud.synchronize()
//        }
    }
    
//    var getNotificationRequest: Action<UserResolver> {
//        return Action { [weak self] in
//            Signal { [weak self] sink in
//                _ = LemonAPI.getNotificationSetting().request().observeNext { (event : EventResolver<User>) in
//                }
//                return BlockDisposable {}
//            }
//        }
//    }
}

class StyleCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var switchOptions: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblTitle.font = UIFont.systemFont(ofSize: 15)
    }
    
    
}

class NotificationStyleViewController: UIViewController {
    var viewModel: NotificationStyleViewModel = NotificationStyleViewModel()

    var dictNotificationSettings: [String:Any] = [:]
    
    var hourString = "0 hours"
    var minString = "0 mins"
    var OrderCountdownWarning = "0 hours 0 mins"
    
    let hoursArray = [
        "0 hours",
        "1 hours",
        "2 hours",
        "3 hours",
        "4 hours",
        "5 hours",
        "6 hours",
    ]
    
    let hoursValueArray = [
        0,
        60,
        120,
        180,
        240,
        300,
        360,
        ]
    
    var minsArray = [
        "0 min",
        "15 min",
        "30 min",
        "45 min",
        
        ]
    
    var minsValueArray = [
        0,
        15,
        30,
        45,
        ]
    
   
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var viewPicker: UIView!
    @IBOutlet weak var viewUIPicker: UIPickerView!
    @IBOutlet weak var txtFieldPicker: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tblView.reloadData()
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 1.0/255.0, green: 180.0/255.0, blue: 208.0/255.0, alpha: 1.0)
    }
    
    @IBAction func bntDoneTapped(_ sender: Any) {
        self.updateNotificationAndContactInfoSetting()
    }
    
    @IBAction func bntPickerDoneTapped(_ sender: Any) {
        self.txtFieldPicker.inputView = nil
        self.txtFieldPicker.resignFirstResponder()
    }
    
    // post method UpdateNotificationAndContactInfoSetting
    func updateNotificationAndContactInfoSetting(){
        var dictParam:[String:Any] = [:]
        if let cell0:StyleCell = self.tblView.cellForRow(at: IndexPath(row: 0, section: 0)) as? StyleCell {
            if let isOn:Bool = cell0.switchOptions.isOn {
                dictParam["IsEnabledPushNotifications"] = isOn
            }
        }
        
        if let cell1:StyleCell = self.tblView.cellForRow(at: IndexPath(row: 1, section: 0)) as? StyleCell {
            if let isOn:Bool = cell1.switchOptions.isOn {
                dictParam["IsEnabledEmailNotifications"] = isOn
            }
        }
        
        if let cell2:StyleCell = self.tblView.cellForRow(at: IndexPath(row: 2, section: 0)) as? StyleCell {
            if let isOn:Bool = cell2.switchOptions.isOn
            {
                dictParam["IsEnabledSMSNotifications"] = isOn
            }
        }
        dictParam["OrderCountdownWarning"] = 30//self.hourString + " " + self.minString
//        dictParam["EmailForContact"] = "borysenko19931128@outlook.com"
//        dictParam["SMSForContact"] = "borysenko19931128@outlook.com"

        DispatchQueue.main.async {
            showLoadingOverlay()
        }
        
        if let url = URL(string: String(format: "%@/UpdateNotificationAndContactInfoSetting", Config.LemonEndpoints.APIEndpoint.rawValue)) {
            
          //  let jsonNotificationSettings = try? JSONSerialization.data(withJSONObject: dictParam)
            
            var headers: [String:String]? = nil
            if let accessToken = LemonAPI.accessToken?.value,
                let userId = LemonAPI.userId {
                headers = [
                    "Authorization": "Bearer \(accessToken)",
                    LemonAPI.USER_ID_HEADER: "\(userId)",
                ]
                  print("accessToken",accessToken)
            }
            let body = NSMutableData()
            for (key, value) in dictParam {
                body.append("&\(key)=\(value)".data(using: String.Encoding.utf8)!)
                
            }
            var request = URLRequest(url: url)
            request.allHTTPHeaderFields = headers
            
            request.httpMethod = "POST"
            
            request.httpBody = body as Data
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                print("UpdateNotificationAndContactInfoSetting \(responseJSON ?? "")")
                DispatchQueue.main.async {
                    hideLoadingOverlay()
                }
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON)
                    if let isSuccess:Bool = responseJSON["IsSuccess"] as? Bool {
                        if isSuccess {
                            self.dictNotificationSettings = responseJSON
                            DispatchQueue.main.async {
                                self.navigationController?.popViewController(animated: true)
//                                if let time = dictParam["OrderCountdownWarning"] as? String
//                                {
//                                 self.OrderCountdownWarning = time
//                                }
//                                self.tblView.reloadData()
                            }
                        }
                    }
                }
            }
            
            task.resume()
        }
        
    }
    
  
    
    
    
    
    
    
    @IBAction func bntPickerCancelTapped(_ sender: Any) {
        
        self.txtFieldPicker.inputView = nil
        self.txtFieldPicker.resignFirstResponder()
        
    }
    
    @IBAction func switchValuehanged(sender: UISwitch) {
    }
}

extension NotificationStyleViewController:UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return hoursArray.count
        }else if component == 1 {
            return minsArray.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            
            
            //return String(format: "%d hours", (row))
           
            return hoursArray[row]
            
            
        }else if component == 1 {
            //return String(format: "%d min", (row*15))
            
           return minsArray[row]
            
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        
        print("\n selected component \(component) row \(row)")
        
        
        if component == 0 {
            hourString = hoursArray[row]
            print("\n selected hour component \(component) row \(row)")
            
        }else if component == 1 {
            minString = minsArray[row]
            print("\n selected min component \(component) row \(row)")
            
        }
        self.OrderCountdownWarning = self.hourString + " " + self.minString
        self.tblView.reloadData()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
//            let indexPath = IndexPath(row: 0, section: 1)
//            let cell: SettingsCell = self.tblView.cellForRow(at: indexPath) as! SettingsCell
//            cell.lblTitle.text = String("Changes to Yellow")
//            cell.lblSubTitle.text = self.hourString + " " + self.minString
//        }
    }
    

}
extension NotificationStyleViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
        if section == 0 {
            lblTitle.text = String("NOTIFICATION STYLE").uppercased()
        }else if section == 1 {
            lblTitle.text = String("ORDER COUNTDOWN WARNNIG").uppercased()
        }else {
            lblTitle.text = ""
        }
        viewTitle.addSubview(lblTitle)
        return viewTitle
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell:StyleCell = tableView.dequeueReusableCell(withIdentifier: String(describing: StyleCell.self), for: indexPath) as? StyleCell ?? StyleCell()
            cell.lblTitle.text = ""
            cell.switchOptions.tag = indexPath.row + 100
            cell.switchOptions.setOn(false, animated: true)
            if indexPath.row == 0 {
                cell.lblTitle.text = String("Push")
                if let isEnabled:Bool = dictNotificationSettings["IsEnabledPushNotifications"] as? Bool {
                    cell.switchOptions.setOn(isEnabled, animated: true)
                }
            }else if indexPath.row == 1 {
                
                cell.lblTitle.text = String("Email")
                
                if let isEnabled:Bool = dictNotificationSettings["IsEnabledEmailNotifications"] as? Bool {
                    cell.switchOptions.setOn(isEnabled, animated: true)
                }
                
            }else if indexPath.row == 2 {
                
                cell.lblTitle.text = String("SMS")
                
                if let isEnabled:Bool = dictNotificationSettings["IsEnabledSMSNotifications"] as? Bool {
                    cell.switchOptions.setOn(isEnabled, animated: true)
                }
            }
            return cell
        }else if indexPath.section == 1 {
            
            let cell:SettingsCell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath) as? SettingsCell ?? SettingsCell()
            cell.lblTitle.text = String("Changes to Yellow")
            cell.lblSubTitle.text = self.OrderCountdownWarning
            
            
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
        }else if indexPath.section == 1 {
            self.txtFieldPicker.inputView = self.viewPicker
            self.txtFieldPicker.becomeFirstResponder()
        }else if indexPath.section == 2 {
            
        }
    }
}


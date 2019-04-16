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
//                    
//                    
//                }
//                return BlockDisposable {}
//
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

    var dataDict = [String:Any]()
    
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

        self.tblView.reloadData()
        getNotificationSetting()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(red: 1.0/255.0, green: 180.0/255.0, blue: 208.0/255.0, alpha: 1.0)
    }
    
    @IBAction func bntPickerDoneTapped(_ sender: Any) {
        self.txtFieldPicker.inputView = nil
        self.txtFieldPicker.resignFirstResponder()
    }
    
//    func getnotificationSettingApi() {
////        viewModel.getNotificationRequest.execute { [weak self] resolver in
////            guard let self = self else {
////                hideLoadingOverlay()
////                return
////            }
////        }
////        _ = LemonAPI.getNotificationSetting().request().observeNext { [weak self] (resolver : EventResolver<[String:Any]>) in
////            do {
////                let dict = try resolver()
////
////            }catch {
////
////            }
////            print("Rakesh")
////        }
//    }
    
    func getNotificationSetting(){
        if let url = URL(string: String(format: "%@/GetNotificationAndContactInfoSetting", Config.LemonEndpoints.APIEndpoint.rawValue)) {
            var request = URLRequest(url: url)
            request.setValue("bearer xMSKXKu30uWJyTE-CoZK_rc-yhyg9y2CKdw31p0lOSS3zTB_ofk0Mt2QnjK6JUH2eMOz3ufDumqPx0VEmJoTFnLvdPWYrYqbB-7KAiJY3r2Hycn7RQwh0jrrSpQ4sjLQKsmsekx064R0r1IIXeV0aMLJ1IhyhjW4HdsQtfLl8u0N_6Pjrw34ACjus2gcXNRSW84hv_7CV_qrgs9TM5dPfd4nTiCo54-j6NoGDfWvFdiZ3iowUJXxZXnF5dYIB0uF", forHTTPHeaderField: "Authorization")
            request.setValue("1070",forHTTPHeaderField:"x-usr-id")
            //request.setValue(LemonAPI.getNotificationSetting.headers, forHTTPHeaderField: )
            
            request.httpMethod = "GET"
            // request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print("responsenotificationSettingJSON",responseJSON)
                    self.dataDict = responseJSON
                }
            }
            task.resume()
        }
    }
    // post method UpdateNotificationAndContactInfoSetting
    func UpdateNotificationAndContactInfoSetting(){
        
        let IsEnabledPushNotifications = 1
        let IsEnabledEmailNotifications = 0
        let IsEnabledSMSNotifications = 1
        let EmailForContact = "n@gmail.com"
        let SMSForContact = "1112"
        let PhoneForContact = "1234"
        let OrderCountdownWarning = "30"
        
        
        let param: [String: Any] = ["IsEnabledPushNotifications": IsEnabledPushNotifications,"IsEnabledEmailNotifications":IsEnabledEmailNotifications,"IsEnabledSMSNotifications":IsEnabledSMSNotifications,"EmailForContact":EmailForContact,"SMSForContact":SMSForContact,"PhoneForContact":PhoneForContact,"OrderCountdownWarning":OrderCountdownWarning]
        let jsonData = try? JSONSerialization.data(withJSONObject: param)
        
        let url = URL(string: "http://11lemons-api-test.azurewebsites.net/api/v1/UpdateNotificationAndContactInfoSetting")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("bearer xMSKXKu30uWJyTE-CoZK_rc-yhyg9y2CKdw31p0lOSS3zTB_ofk0Mt2QnjK6JUH2eMOz3ufDumqPx0VEmJoTFnLvdPWYrYqbB-7KAiJY3r2Hycn7RQwh0jrrSpQ4sjLQKsmsekx064R0r1IIXeV0aMLJ1IhyhjW4HdsQtfLl8u0N_6Pjrw34ACjus2gcXNRSW84hv_7CV_qrgs9TM5dPfd4nTiCo54-j6NoGDfWvFdiZ3iowUJXxZXnF5dYIB0uF", forHTTPHeaderField: "Authorization")
        request.setValue("1070",forHTTPHeaderField:"x-usr-id")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print("UpdateNotificationAndContactInfoSetting",responseJSON)
            }
        }
        
        task.resume()
    }
    
  
    
    
    
    
    
    
    @IBAction func bntPickerCancelTapped(_ sender: Any) {
        
        self.txtFieldPicker.inputView = nil
        self.txtFieldPicker.resignFirstResponder()
        
    }
    
    @IBAction func switchValuehanged(sender: UISwitch) {
        
        //        let IsEnabledPushNotifications = notificationDict.value(forKey: "IsEnabledPushNotifications")
        //       let IsEnabledEmailNotifications = notificationDict.value(forKey: "IsEnabledEmailNotifications")
        //        let IsEnabledSMSNotifications = notificationDict.value(forKey: "IsEnabledSMSNotifications")
        //        let EmailForContact = notificationDict.value(forKey: "EmailForContact")
        //        let SMSForContact = notificationDict.value(forKey: "SMSForContact")
        //        let PhoneForContact = notificationDict.value(forKey: "PhoneForContact")
        //         let OrderCountdownWarning = notificationDict.value(forKey: "OrderCountdownWarning")
        
        print("\n switchValuehanged \(sender.tag) -  \(sender.isOn)")
        if(sender.tag == 100)
        {
           dataDict["IsEnabledPushNotifications"] = sender.isOn ? "true" : "false"

        }
        else if(sender.tag == 101)
        {
            dataDict["IsEnabledEmailNotifications"] = sender.isOn ? "true" : "false"

        }
        else if(sender.tag == 102)
        {
           dataDict["IsEnabledSMSNotifications"] = sender.isOn ? "true" : "false"

        }
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
            
            print("\n selected hour component \(component) row \(row)")
            
        }else if component == 1 {
           
            print("\n selected min component \(component) row \(row)")
            
        }
        
        
        
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
            if indexPath.row == 0 {
                
                cell.lblTitle.text = String("Push")
                if dataDict["IsEnabledPushNotifications"] as? String == "true"
                {
                     cell.switchOptions.setOn(true, animated: false)
                }else
                {
                     cell.switchOptions.setOn(false, animated: false)
                }
                
                
            }else if indexPath.row == 1 {
                
                cell.lblTitle.text = String("Email")
                
                if dataDict["IsEnabledEmailNotifications"]as? String == "true"
                {
                    cell.switchOptions.setOn(true, animated: false)
                }else
                {
                    cell.switchOptions.setOn(false, animated: false)
                }
                
                
            }else if indexPath.row == 2 {
                
                cell.lblTitle.text = String("SMS")
                
                if dataDict["IsEnabledSMSNotifications"]as? String == "true"
                {
                    cell.switchOptions.setOn(true, animated: false)
                }else
                {
                    cell.switchOptions.setOn(false, animated: false)
                
                }
            }
            return cell
        }else if indexPath.section == 1 {
            
            let cell:SettingsCell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath) as? SettingsCell ?? SettingsCell()
            cell.lblTitle.text = String("Changes to Yellow")
            cell.lblSubTitle.text = "30 Minutes"
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


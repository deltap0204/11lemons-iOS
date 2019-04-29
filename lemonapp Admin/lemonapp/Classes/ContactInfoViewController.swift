//
//  ContactInfoViewController.swift
//  DemoTableView
//
//  Created by Apple on 13/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import MessageUI

func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
    guard !phoneNumber.isEmpty else { return "" }
    guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
    let r = NSString(string: phoneNumber).range(of: phoneNumber)
    var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")
    
    if number.count > 10 {
        let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
        number = String(number[number.startIndex..<tenthDigitIndex])
    }
    
    if shouldRemoveLastDigit {
        let end = number.index(number.startIndex, offsetBy: number.count-1)
        number = String(number[number.startIndex..<end])
    }
    
    if number.count < 7 {
        let end = number.index(number.startIndex, offsetBy: number.count)
        let range = number.startIndex..<end
        number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)
        
    } else {
        let end = number.index(number.startIndex, offsetBy: number.count)
        let range = number.startIndex..<end
        number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: range)
    }
    
    return number
}

class ContactInfoCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtFieldInput: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblTitle.font = UIFont.systemFont(ofSize: 15)
    }
}

class ContactInfoViewController: UIViewController {
    @IBOutlet weak var tblView: UITableView!
    var dictContactInfo:[String:Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblView.reloadData()
    }
    @IBAction func bntDoneTapped(_ sender: Any) {
        self.updateNotificationAndContactInfoSetting()
    }
    // post method UpdateNotificationAndContactInfoSetting
    func updateNotificationAndContactInfoSetting(){
        if let cell0:ContactInfoCell = self.tblView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ContactInfoCell {
            if var str:String = cell0.txtFieldInput.text {
                if str.isEmpty == false {
                    str = str.replacingOccurrences(of: "(", with: "")
                    str = str.replacingOccurrences(of: ")", with: "")
                    str = str.replacingOccurrences(of: " ", with: "")
                    str = str.replacingOccurrences(of: "-", with: "")
                    self.dictContactInfo["PhoneForContact"] = str
                }
            }
        }
        
        if let cell0:ContactInfoCell = self.tblView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ContactInfoCell {
            if var str:String = cell0.txtFieldInput.text {
                if str.isEmpty == false {
                    str = str.replacingOccurrences(of: "(", with: "")
                    str = str.replacingOccurrences(of: ")", with: "")
                    str = str.replacingOccurrences(of: " ", with: "")
                    str = str.replacingOccurrences(of: "-", with: "")
                    self.dictContactInfo["SMSForContact"] = str
                }
            }
        }
        
        if let cell0:ContactInfoCell = self.tblView.cellForRow(at: IndexPath(row: 2, section: 0)) as? ContactInfoCell {
            if let str:String = cell0.txtFieldInput.text {
                if str.isEmpty == false {
                    self.dictContactInfo["EmailForContact"] = str
                }
            }
        }
        
        
        if let url = URL(string: String(format: "%@/UpdateNotificationAndContactInfoSetting", Config.LemonEndpoints.APIEndpoint.rawValue)) {
            
            var headers: [String:String]? = nil
            if let accessToken = LemonAPI.accessToken?.value,
                let userId = LemonAPI.userId {
                headers = [
                    "Authorization": "Bearer \(accessToken)",
                    LemonAPI.USER_ID_HEADER: "\(userId)"
                ]
            }

            let body = NSMutableData()
            for (key, value) in self.dictContactInfo {
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
                print("UpdateNotificationAndContactInfoSetting \(String(describing: responseJSON))")
                if let responseJSON = responseJSON as? [String: Any] {
                    if let isSuccess:Bool = responseJSON["IsSuccess"] as? Bool {
                        if isSuccess {
                            self.dictContactInfo = responseJSON
                            DispatchQueue.main.async {
                                self.tblView.reloadData()
                            }
                        }
                    }
                }
            }
            
            task.resume()
        }
        
    }
    
}

extension ContactInfoViewController:UITableViewDelegate, UITableViewDataSource ,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
            lblTitle.text = String("CUSTOMER SUPPORT").uppercased()
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
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell:ContactInfoCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ContactInfoCell.self), for: indexPath) as? ContactInfoCell ?? ContactInfoCell()
            cell.lblTitle.text = ""
            cell.txtFieldInput.tag = indexPath.row+100
            cell.txtFieldInput.delegate = self
            
            if indexPath.row == 0 {
                cell.lblTitle.text = String("Phone")
                cell.txtFieldInput.placeholder = String("(000) 000-0000")
                if let str:String = self.dictContactInfo["PhoneForContact"] as? String {
                    if str.isEmpty == false {
                        cell.txtFieldInput.text = format(phoneNumber: str)
                    }
                }
            }else if indexPath.row == 1 {
                cell.lblTitle.text = String("SMS")
                cell.txtFieldInput.placeholder = String("(000) 000-0000")
                if let str:String = self.dictContactInfo["SMSForContact"] as? String {
                    if str.isEmpty == false {
                        cell.txtFieldInput.text = format(phoneNumber: str)
                    }
                }
            }else if indexPath.row == 2 {
                cell.lblTitle.text = String("Email")
                cell.txtFieldInput.placeholder = String("email@email.com")
                if let str:String = self.dictContactInfo["EmailForContact"] as? String {
                    if str.isEmpty == false {
                        cell.txtFieldInput.text = str
                    }
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let indexPath = tableView.indexPathForSelectedRow
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! ContactInfoCell
        print(currentCell.txtFieldInput.text!);

        if indexPath?.section == 0 {
            
            if indexPath?.row == 1{
                self.callNumber(phoneNumber: currentCell.txtFieldInput.text!)
            }
         else  if indexPath?.row == 1{
                self.sendSMSText(phoneNumber: currentCell.txtFieldInput.text! )
            }
        else  if indexPath?.row == 2{
                self.sendEmailButtonTapped(email: currentCell.txtFieldInput.text!)
            }

        }else if indexPath?.section == 1 {
        }else if indexPath?.section == 2 {
            
        }
    }
    func callNumber(phoneNumber:String) {
        
        if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    application.openURL(phoneCallURL as URL)
                    
                }
            }
        }
    }
    func sendSMSText(phoneNumber: String) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = ""
            controller.recipients = [phoneNumber]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }else{
            
            let sendMailErrorAlert = UIAlertView(title: "Could Not Send SMS", message: "Your device could not send SMS.", delegate: self, cancelButtonTitle: "OK")
            sendMailErrorAlert.show()

        }
    }
    
     func sendEmailButtonTapped(email: String) {
       // let mailComposeViewController = configuredMailComposeViewController()
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([email])
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["someone@somewhere.com"])
        //mailComposerVC.setSubject("Support team")
       // mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
}

extension ContactInfoViewController:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.tag == 102 {
            return true;
        }
        var fullString = textField.text ?? ""
        
        fullString.append(string)
        if range.length == 1 {
            textField.text = format(phoneNumber: fullString, shouldRemoveLastDigit: true)
        } else {
            textField.text = format(phoneNumber: fullString)
        }
        return false
    }
    
}

//
//  NotificationViewController.swift
//  lemonapp
//
//  Created by David Bucci on 12/04/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate{
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var tblNotification: UITableView!
    @IBOutlet weak var txt_pickUpData: UITextField!
    
    let notificatioArr = ["PUSH", "EMAIL", "SMS"]
    
    var pickerData = ["0 Hour 15 Minutes" , "1 Hour 15 Minutes" , "15 Minutes" , "30 Minutes"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
       pickerView.isHidden = true
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func pickUp(_ textField : UITextField){
          // UIPickerView
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerView.backgroundColor = UIColor.white
       
        
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NotificationViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NotificationViewController.cancelClick))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        txt_pickUpData.inputView = self.pickerView
        txt_pickUpData.inputAccessoryView = toolBar
    }
    
   
    
    
    //MARK:- PickerView Delegate & DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.txt_pickUpData.text = pickerData[row]
    }
    //MARK:- TextFiled Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pickUp(txt_pickUpData)
         pickerView.isHidden = false
        
    }
    
    //MARK:- Button
    @objc func doneClick() {
        txt_pickUpData.resignFirstResponder()
    }
    @objc func cancelClick() {
        txt_pickUpData.resignFirstResponder()
    }
}
extension NotificationViewController : UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return 64
    }
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificatioArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! notificationCell
        
          cell.lblName.text = notificatioArr[indexPath.row]
        
        //        if indexPath.row == 0{
        //            cell.lblserviceName.isHidden = true
        //            cell.lblRushService.isHidden = true
        //            cell.lblLeft.text = "Notifications"
        //        }
        //        if indexPath.row == 1{
        //            cell.lblserviceName.isHidden = false
        //            cell.lblserviceName.text = "CUSTOMER SERVICE"
        //            cell.lblRushService.isHidden = true
        //            cell.lblLeft.text = "Contact Information"
        //        }
        //        if indexPath.row == 2{
        //            cell.lblserviceName.isHidden = false
        //            cell.lblserviceName.text = "BUSINESS INFORMATION"
        //            cell.lblRushService.isHidden = false
        //            cell.lblRushService.text = "Rush Services can  be  customized in the Hours of Opration Section"
        //            cell.lblLeft.text = "Hours Of Operation"
        //        }
        //
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
}


class  notificationCell: UITableViewCell{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var `switch`: UISwitch!
    
}

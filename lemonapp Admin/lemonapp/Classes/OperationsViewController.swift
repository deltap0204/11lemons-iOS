//
//  OperationsViewController.swift
//  DemoTableView
//
//  Created by Apple on 13/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class OperationsViewController: UIViewController {
    @IBOutlet weak var tblView: UITableView!
    let aryDays:[[String:Any]] = [["day":"Monday", "time":"9:00 am to 10:00 pm"], ["day":"Tuesday", "time":"9:00 am to 10:00 pm"], ["day":"Wednesday", "time":"9:00 am to 10:00 pm"], ["day":"Thursday", "time":"9:00 am to 10:00 pm"], ["day":"Friday", "time":"9:00 am to 10:00 pm"], ["day":"Saturday", "time":"9:00 am to 10:00 pm"], ["day":"Sunday", "time":"Closed"], ]
    override func viewDidLoad() {
        super.viewDidLoad()
               getHoursOfOperation()
        self.tblView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // navigationController?.navigationBar.barTintColor = UIColor(red: 1.0/255.0, green: 180.0/255.0, blue: 208.0/255.0, alpha: 1.0)

    }
    // getHoursofOperation
    
    func getHoursOfOperation(){
        
        let url = URL(string:"http://11lemons-api-test.azurewebsites.net/api/v1/GetHoursOfOperations")!
        var request = URLRequest(url: url)
        request.setValue("bearer xMSKXKu30uWJyTE-CoZK_rc-yhyg9y2CKdw31p0lOSS3zTB_ofk0Mt2QnjK6JUH2eMOz3ufDumqPx0VEmJoTFnLvdPWYrYqbB-7KAiJY3r2Hycn7RQwh0jrrSpQ4sjLQKsmsekx064R0r1IIXeV0aMLJ1IhyhjW4HdsQtfLl8u0N_6Pjrw34ACjus2gcXNRSW84hv_7CV_qrgs9TM5dPfd4nTiCo54-j6NoGDfWvFdiZ3iowUJXxZXnF5dYIB0uF", forHTTPHeaderField: "Authorization")
        request.setValue("1070",forHTTPHeaderField:"x-usr-id")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "GET"
        // request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print("responseHoursOfOperation",responseJSON)
            }
        }
        
        task.resume()
    }
    
    // getHoursofSpecificDayOperation
    
    func getHoursOfspecificDayOperation(){
        
        let url = URL(string:"http://11lemons-api-test.azurewebsites.net/api/v1/GetHoursOfOperations")!
        var request = URLRequest(url: url)
        request.setValue("bearer xMSKXKu30uWJyTE-CoZK_rc-yhyg9y2CKdw31p0lOSS3zTB_ofk0Mt2QnjK6JUH2eMOz3ufDumqPx0VEmJoTFnLvdPWYrYqbB-7KAiJY3r2Hycn7RQwh0jrrSpQ4sjLQKsmsekx064R0r1IIXeV0aMLJ1IhyhjW4HdsQtfLl8u0N_6Pjrw34ACjus2gcXNRSW84hv_7CV_qrgs9TM5dPfd4nTiCo54-j6NoGDfWvFdiZ3iowUJXxZXnF5dYIB0uF", forHTTPHeaderField: "Authorization")
        request.setValue("1070",forHTTPHeaderField:"x-usr-id")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "GET"
        // request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print("responseHoursOfOperation",responseJSON)
            }
        }
        
        task.resume()
    }
    
}

extension OperationsViewController:UITableViewDelegate, UITableViewDataSource {
    
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
        lblTitle.text = String("Hours of Operation").uppercased()
        viewTitle.addSubview(lblTitle)
        return viewTitle
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.aryDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SettingsCell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath) as? SettingsCell ?? SettingsCell()
        
        cell.lblTitle.text = ""
        cell.lblSubTitle.text = ""
        if let dict:[String:Any] = self.aryDays[indexPath.row] as? [String:Any] {
            if let str:String = dict["day"] as? String {
                cell.lblTitle.text = str
            }
            if let str:String = dict["time"] as? String {
                cell.lblSubTitle.text = str
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
            var strDayName:String = "" ;
            if let dict:[String:Any] = self.aryDays[indexPath.row] as? [String:Any] {
                if let str:String = dict["day"] as? String {
                    
                    strDayName = str;
                }
            }
                if(indexPath.row == 6){
                let vc:DayOperationsViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: DayOperationsViewController.self)) as? DayOperationsViewController ?? DayOperationsViewController()
                vc.isSunday = true;
                vc.strDay = strDayName;
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                let vc:DayOperationsViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: DayOperationsViewController.self)) as? DayOperationsViewController ?? DayOperationsViewController()
                vc.isSunday = false;
                vc.strDay = strDayName;

                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }else if indexPath.section == 1 {
            let vc:ContactInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ContactInfoViewController.self)) as? ContactInfoViewController ?? ContactInfoViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.section == 2 {
            
        }
    }
}

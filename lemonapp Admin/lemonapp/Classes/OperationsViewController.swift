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
     var dictHours:[String:Any] = [:]
      var dictupdateHours:[String:Any] = [:]
      var dictHoursOperation:[String:Any] = [:]

    
    var aryDays:[[String:Any]] = [ ]
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getHoursOperation()
        self.tblView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // navigationController?.navigationBar.barTintColor = UIColor(red: 1.0/255.0, green: 180.0/255.0, blue: 208.0/255.0, alpha: 1.0)

    }
    func getHoursOperation(){
        if let url = URL(string: String(format: "%@/GetHoursOfOperations", Config.LemonEndpoints.APIEndpoint.rawValue)) {
            
            var headers: [String:String]? = nil
            if let accessToken = LemonAPI.accessToken?.value,
                let userId = LemonAPI.userId {
                headers = [
                    "Authorization": "Bearer \(accessToken)",
                    LemonAPI.USER_ID_HEADER: "\(userId)"
                ]
                print("accessToken",accessToken)
            }
           
            
            var request = URLRequest(url: url)
            request.allHTTPHeaderFields = headers
            
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print("responsedictHoursOperation",responseJSON)
                   // self.dictHoursOperation = responseJSON
                    if let ary = responseJSON["OperationHours"] as? [[String:Any]] {
                        print("responsedictHoursOperation",responseJSON)
                        self.aryDays = ary;
                        // self.dictHoursOperation = responseJSON
                        DispatchQueue.main.async {
                            self.tblView.reloadData()
                        }
                    }
                    
                }
            }
            task.resume()
        }
    }
    func UpdateHoursOfOperations(){
            if let url = URL(string: String(format: "%@/UpdateHoursOfOperations", Config.LemonEndpoints.APIEndpoint.rawValue)) {
                
                var headers: [String:String]? = nil
                if let accessToken = LemonAPI.accessToken?.value,
                    let userId = LemonAPI.userId {
                    headers = [
                        "Authorization": "Bearer \(accessToken)",
                        LemonAPI.USER_ID_HEADER: "\(userId)"
                    ]
                }
//                headers = [
//                    "Authorization": "bearer YZnmUgR0Xr7eG9Ghnwi-EFYm8Sa93uhn-fE2Z0aWJ-7cIUYemU9XFvXsXaI5l107vbTucN2_PPqYFR6tL115U5WeFvpsLs59UFd3BKX7WYTyVaKvyDbB5VTAaONjKqlEpVEj2ik-HyuSgV8BD-We7wNeYM0sYHtmDR4LGMbcBdRcSbr0r_p9Yfhx-Z85luVcuV8chn6B9pJSH18nXGKF8KH0iqr5fi03MoRgVFfgvMwyr3f1l7ty4R5rnvHczAte",
//                    LemonAPI.USER_ID_HEADER: "1070"
//                ]
                
                var request = URLRequest(url: url)
                request.allHTTPHeaderFields = headers
                
                request.httpMethod = "POST"
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    print("responsedictSpecificHours",response!)
                    guard let data = data, error == nil else {
                        print(error?.localizedDescription ?? "No data")
                        return
                    }
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let responseJSON = responseJSON as? [String: Any] {
                        if let isSuccess:Bool = responseJSON["IsSuccess"] as? Bool {
                            if isSuccess {
                                print("responseJSONdictSpecificHours",responseJSON)
                                self.dictupdateHours = responseJSON
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
    
    @IBAction func btnDone(_ sender: Any) {
        UpdateHoursOfOperations()
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
        if let dict:[String:Any] = self.aryDays[indexPath.row] {
            if let strDayName:String = dict["DayName"] as? String,
                let strOpenTime:String = dict["OpenTime"] as? String,
                let strCloseTime:String = dict["CloseTime"] as? String {
                
                cell.lblTitle.text =  strDayName
                
                cell.lblSubTitle.text =  strOpenTime + "-" + strCloseTime
                if let isClosed:Bool = dict["IsClosed"] as? Bool {
                    if isClosed {
                        cell.lblSubTitle.text = "Closed"
                    }
                }
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let  dict:[String:Any] = self.aryDays[indexPath.row] else {
                return
            }
            
            var strDayName:String = "" ;
            
            if let str:String = dictHours["DayName"] as? String {
                
                strDayName = str;
            }
            let vc:DayOperationsViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: DayOperationsViewController.self)) as? DayOperationsViewController ?? DayOperationsViewController()
            
            
            if(indexPath.row == 0){
                vc.isSunday = true;
            }else{
                vc.isSunday = false;
            }
            vc.strDay = strDayName;
            vc.dictOperationDetail = dict
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}

//
//  DayOperationsViewController.swift
//  DemoTableView
//
//  Created by Apple on 13/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class DayOperationsCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInput: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblTitle.font = UIFont.systemFont(ofSize: 15)
        
    }
}

class DayOperationsViewController: UIViewController {
	
	var dayInteger = 0;
    var strCloseTime = "";
    var strOpenTime = ""
    
    var strCustomBeginDeliveryTime = ""
    var strCustomEndDeliveryTime = ""
    
    var strNextDayServiceCustoff = ""
    var strNextDayServiceUpcharge = ""
    
    var strSameDayServiceCustoff = ""
    var strSameDayServiceUpcharge = ""
    
    var isOpenForBusiness:Bool = false
    var isCustom:Bool = false
    var isSameDayService:Bool = false
    var isNextDayService:Bool = false
    
    @IBOutlet weak var tblView: UITableView!
    
    var isSunday: Bool!
    var strDay: String!
    var dictOperationDetail:[String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
		self.updateDetails()
	}
	
	@IBAction func datePikcerChangeValue(sender: UIDatePicker) {
		let selectedDate = sender.date
		let calendar = Calendar.current
		let comp = calendar.dateComponents([.hour, .minute], from: selectedDate)
		let hour = comp.hour
		let minute = comp.minute
		let time = String(format:"%02d:%02d %@", ((hour ?? 1)%12) as CVarArg, minute  as! CVarArg, ((hour ?? 01)>12) ? "PM" : "AM")
		if sender.tag == 100001 {
			self.strOpenTime = time
			let indexPath = IndexPath(row: 1, section: 0)
			let cell: SettingsCell = self.tblView.cellForRow(at: indexPath) as! SettingsCell
			cell.lblTitle.text = String("Open")
			cell.txtFieldTitle.text = self.strOpenTime
		}else if sender.tag == 100002 {
			self.strCloseTime = time
			
			let indexPath = IndexPath(row: 2, section: 0)
			let cell: SettingsCell = self.tblView.cellForRow(at: indexPath) as! SettingsCell
			cell.lblTitle.text = String("Close")
			cell.txtFieldTitle.text = self.strCloseTime
		}
			
		else if sender.tag == 100003 {
			self.strCustomBeginDeliveryTime = time
			
			let indexPath = IndexPath(row: 1, section: 1)
			let cell: SettingsCell = self.tblView.cellForRow(at: indexPath) as! SettingsCell
			cell.lblTitle.text = String("Begin Deliveries")
			cell.txtFieldTitle.text = self.strCustomBeginDeliveryTime
		}else if sender.tag == 100004 {
			self.strCustomEndDeliveryTime = time
			
			let indexPath = IndexPath(row: 2, section: 1)
			let cell: SettingsCell = self.tblView.cellForRow(at: indexPath) as! SettingsCell
			cell.lblTitle.text = String("End Deliveries")
			cell.txtFieldTitle.text = self.strCustomEndDeliveryTime
		}
			
		else if sender.tag == 100005 {
			self.strSameDayServiceCustoff = time
			
			let indexPath = IndexPath(row: 2, section: 2)
			let cell: SettingsCell = self.tblView.cellForRow(at: indexPath) as! SettingsCell
			cell.lblTitle.text = String("Cutoff")
			cell.txtFieldTitle.text = self.strSameDayServiceCustoff
			
		}else if sender.tag == 100006 {
			self.strNextDayServiceCustoff = time
			
			let indexPath = IndexPath(row: 2, section: 3)
			let cell: SettingsCell = self.tblView.cellForRow(at: indexPath) as! SettingsCell
			cell.lblTitle.text = String("Cutoff")
			cell.txtFieldTitle.text = self.strNextDayServiceCustoff
		}
		//self.tblView.reloadData()
		
	}
	
	
    @IBAction func switchValuehanged(sender: UISwitch) {
		print(sender.isOn)
		if sender.tag == 100 {
            self.isOpenForBusiness = sender.isOn
        }else if sender.tag == 200 {
            self.isCustom = sender.isOn
        }else if sender.tag == 300 {
            self.isSameDayService = sender.isOn
        }else if sender.tag == 400 {
            self.isNextDayService = sender.isOn
        }
       // self.tblView.reloadData()
    }
	
	@IBAction func btnDoneTapped(sender: UIButton) {
		self.updateHoursOfOperation()
	}
	
	func updateDetails(){
		DispatchQueue.main.async {
			//self.title = strDay;
			//strDay
			if let titleName = self.dictOperationDetail["DayName"] as? String {
				self.title  = titleName
			}
			
			if let dayInteger = self.dictOperationDetail["DayIneger"] as? Int {
				self.dayInteger  = dayInteger
			}
			
			if let isClosed:Bool = self.dictOperationDetail["IsClosed"] as? Bool {
				self.isOpenForBusiness = isClosed
			}
			
			if let isClosed:Bool = self.dictOperationDetail["HasCustomDeliveryHours"] as? Bool {
				self.isCustom = isClosed
			}
			
			if let isClosed:Bool = self.dictOperationDetail["HasSameDayService"] as? Bool {
				self.isSameDayService = isClosed
			}
			
			if let isClosed:Bool = self.dictOperationDetail["HasNextDayService"] as? Bool {
				self.isNextDayService = isClosed
			}
			
			if let str = self.dictOperationDetail["OpenTime"] as? String{
					self.strOpenTime = String(format:"%@", str)
			}else
			{
				self.strOpenTime = "00:00"
			}
			
			if let str = self.dictOperationDetail["CloseTime"] as? String{
				    self.strCloseTime = String(format:"%@", str )
			}else
			{
				self.strCloseTime = "00:00"
			}
			
			if let str = self.dictOperationDetail["CustomBeginDeliveryTime"] as? String{
				   self.strCustomBeginDeliveryTime = String(format:"%@", str)
			}else
			{
				self.strCustomBeginDeliveryTime = "00:00"
			}
			
			if let str = self.dictOperationDetail["CustomEndDeliveryTime"]  as? String{
				self.strCustomEndDeliveryTime = String(format:"%@", str)
			}else
			{
				self.strCustomEndDeliveryTime = "00:00"
			}
			
			if let str = self.dictOperationDetail["SameDayServiceUpcharge"] {
				self.strSameDayServiceUpcharge = String(format:"%@", str as! CVarArg)
			}
			
			if let str = self.dictOperationDetail["SameDayServiceCustoff"] as? String {
				self.strSameDayServiceCustoff = String(format:"%@", str)
			}else
			{
				self.strSameDayServiceCustoff = "00:00"
			}
			
			if let str = self.dictOperationDetail["NextDayServiceUpcharge"] {
				self.strNextDayServiceUpcharge = String(format:"%@", str as! CVarArg)
			}
			
			if let str = self.dictOperationDetail["NextDayServiceCustoff"] as? String{
				self.strNextDayServiceCustoff = String(format:"%@", str)
			}else
			{
				self.strNextDayServiceCustoff = "00:00"
			}
			
			self.tblView.reloadData()
		}
	}
	
	func updateHoursOfOperation(){
//		let param: [String: Any] = ["DayIneger": "1",
//									"IsClosed":self.isOpenForBusiness,
//									"OpenTime":self.strDay,
//									"CloseTime":self.strCloseTime,
//									"HasCustomDeliveryHours":self.isCustom,
//									"CustomBeginDeliveryTime":self.strCustomBeginDeliveryTime,
//									"CustomEndDeliveryTime":self.strCustomBeginDeliveryTime,
//									"SameDayServiceUpcharge,":self.strSameDayServiceUpcharge,
//									"SameDayServiceCustoff,":self.strSameDayServiceCustoff,
//									"NextDayServiceUpcharge,":self.strNextDayServiceUpcharge,
//									"NextDayServiceCustoff":self.strNextDayServiceCustoff
//		]
		
		
		let param: [String: Any] = ["DayIneger": self.dayInteger,
									"IsClosed":self.isOpenForBusiness,
									"OpenTime":self.strOpenTime,
									"CloseTime":self.strCloseTime,
									"HasCustomDeliveryHours":self.isCustom,
									"CustomBeginDeliveryTime":self.strCustomBeginDeliveryTime,
									"CustomEndDeliveryTime":self.strCustomBeginDeliveryTime,
									"SameDayServiceUpcharge":self.strSameDayServiceUpcharge,
									"SameDayServiceCustoff":self.strSameDayServiceCustoff,
									"NextDayServiceUpcharge":self.strNextDayServiceUpcharge,
									"NextDayServiceCustoff":self.strNextDayServiceCustoff,
									"HasNextDayService":self.isNextDayService,
									"HasSameDayService":self.isSameDayService
		]
		//strOpenTime
		let body = NSMutableData()
		for (key, value) in param {
			body.append("&\(key)=\(value)".data(using: String.Encoding.utf8)!)
			
		}
		let url = URL(string: "http://11lemonsposapilive.azurewebsites.net/api/v1/updateHoursOfOperations")!
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		var headers: [String:String]? = nil
		if let accessToken = LemonAPI.accessToken?.value,
			let userId = LemonAPI.userId {
			headers = [
				"Authorization": "Bearer \(accessToken)",
				LemonAPI.USER_ID_HEADER: "\(userId)"
			]
		}

		request.allHTTPHeaderFields = headers
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.httpBody = body as Data
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data, error == nil else {
				print(error?.localizedDescription ?? "No data")
				return
			}
			let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
			if let responseJSON = responseJSON as? [String: Any] {
				print("UpdateHoursOperation",responseJSON)
				
				DispatchQueue.main.async {
				self.navigationController?.popViewController(animated: true)
				}
//				let dataArray = responseJSON as! NSArray
//				for dataDict:[String:Any] in dataArray {
//					if self.dataDict["DayIneger"] as? Int == self.dayInteger{
//						self.dayInteger  = dayInteger
//					}
//				}
//				self.dictOperationDetail = responseJSON
//				self.updateDetails()
			}
		}
		
		task.resume()
	}
}

extension DayOperationsViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSunday {
            return 1
        } else {
            return 4
            
        }
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
        if isSunday == false {
            let viewTitle = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:44))
            let lblTitle = UILabel(frame: CGRect(x:15, y:10, width:tableView.frame.size.width-30, height:30))
            lblTitle.font = UIFont.systemFont(ofSize: 14)
            if section == 0 {
                lblTitle.text = String("BUSINESS HOURS").uppercased()
            }
            else if section == 1 {
                lblTitle.text = String("DELIVERY HOURS").uppercased()
            }
            else if section == 2 {
                lblTitle.text = String("SAME DAY SERVICE").uppercased()
            }
            else if section == 3 {
                lblTitle.text = String("NEXT DAY SERVICE").uppercased()
            }
            else {
                lblTitle.text = ""
            }
            viewTitle.addSubview(lblTitle)
            return viewTitle
        }
        return nil;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSunday {
            return 1
        } else {
//            if section == 0 {
//                return self.isOpenForBusiness ? 3 : 1
//            }else if section == 1 {
//                return self.isCustom ? 3 : 1
//            }else if section == 2 {
//                return self.isSameDayService ? 3 : 1
//            }else if section == 3 {
//                return self.isNextDayService ? 3 : 1
//            }
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isSunday {
            let cell:StyleCell = tableView.dequeueReusableCell(withIdentifier: String(describing: StyleCell.self), for: indexPath) as? StyleCell ?? StyleCell()
            cell.lblTitle.text = ""
            cell.lblTitle.text = String("Open for Business ")
            if let isClosed:Bool = self.dictOperationDetail["IsClosed"] as? Bool {
                cell.switchOptions.isOn = isClosed;
            }
            return cell
        } else {
            if indexPath.row==0 {
                let cell:StyleCell = tableView.dequeueReusableCell(withIdentifier: String(describing: StyleCell.self), for: indexPath) as? StyleCell ?? StyleCell()
                cell.lblTitle.text = ""
				cell.switchOptions.addTarget(self, action: #selector(self.switchValuehanged(sender:)), for: .valueChanged)
                if indexPath.section == 0 {
					print("self.isOpenForBusiness \(self.isOpenForBusiness)")
                    cell.switchOptions.tag = 100
                    cell.lblTitle.text = String("Open for Business")
                    cell.switchOptions.isOn = self.isOpenForBusiness
                }else if indexPath.section == 1 {
                    cell.switchOptions.tag = 200
                    cell.lblTitle.text = String("Custom")
                    cell.switchOptions.isOn = self.isCustom;
                }else if indexPath.section == 2 {
                    cell.switchOptions.tag = 300
                    cell.lblTitle.text = String("Same Day Service")
                    cell.switchOptions.isOn = self.isSameDayService;
                }else if indexPath.section == 3 {
                    cell.switchOptions.tag = 400
                    cell.lblTitle.text = String("Next Day Service")
                    cell.switchOptions.isOn = self.isNextDayService;
                }
                return cell
                
            }else{
                let cell:SettingsCell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath) as? SettingsCell ?? SettingsCell()
                cell.lblTitle.text = ""
				cell.txtFieldTitle.text = ""
				cell.txtFieldTitle.delegate = self
				
				let datePikcer = UIDatePicker()
				datePikcer.datePickerMode = .time
				datePikcer.addTarget(self, action: #selector(datePikcerChangeValue), for: .valueChanged)
				
				cell.txtFieldTitle.inputView = datePikcer
				
				if indexPath.section == 0 {
				    if indexPath.row == 1 {
						datePikcer.tag = 100001
                        cell.lblTitle.text = String("Open")
                        cell.txtFieldTitle.text = self.strOpenTime
                    }
                    else if indexPath.row == 2{
						datePikcer.tag = 100002
                        cell.lblTitle.text = String("Close")
                        cell.txtFieldTitle.text = self.strCloseTime
                    }
				}else if indexPath.section == 1 {
                    if indexPath.row == 1{
                        cell.lblTitle.text = String("Begin Deliveries")
                        cell.txtFieldTitle.text = self.strCustomBeginDeliveryTime
						datePikcer.tag = 100003
                    }
                    else if indexPath.row == 2{
                        cell.lblTitle.text = String("End Deliveries")
                        cell.txtFieldTitle.text = self.strCustomEndDeliveryTime
						datePikcer.tag = 100004
                    }
                }else if indexPath.section == 2 {
                    if indexPath.row == 1{
                        cell.lblTitle.text = String("Upcharge")
                        cell.txtFieldTitle.text = self.strSameDayServiceUpcharge
						cell.txtFieldTitle.inputView = nil
						cell.txtFieldTitle.tag = 200005
						cell.txtFieldTitle.keyboardType = .decimalPad
                    }
                    else if indexPath.row == 2{
                        cell.lblTitle.text = String("Cutoff")
                        cell.txtFieldTitle.text = self.strSameDayServiceCustoff
						datePikcer.tag = 100005
                    }
                }
                if indexPath.section == 3 {
                    if indexPath.row == 1{
                        cell.lblTitle.text = String("Upcharge")
                        cell.txtFieldTitle.text = self.strNextDayServiceUpcharge
						cell.txtFieldTitle.inputView = nil
						cell.txtFieldTitle.tag = 200007
						cell.txtFieldTitle.keyboardType = .decimalPad
                    }
                    else if indexPath.row == 2{
                        cell.lblTitle.text = String("Cutoff")
                        cell.txtFieldTitle.text = self.strNextDayServiceCustoff
						datePikcer.tag = 100006
                    }
                }
                return cell
                
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
        }else if indexPath.section == 1 {
            
        }else if indexPath.section == 2 {
            
        }
    }
}

extension DayOperationsViewController:UITextFieldDelegate {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if let text = textField.text, let textRange = Range(range, in: text) {
			let updatedText = text.replacingCharacters(in: textRange,  with: string)
		
			if textField.tag == 200005 {
				self.strSameDayServiceUpcharge = updatedText
			}else if textField.tag == 200007 {
				self.strNextDayServiceUpcharge = updatedText
			}
		}
		return true
	}
	
}

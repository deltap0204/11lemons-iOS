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

    @IBOutlet weak var tblView: UITableView!
    
     var isSunday: Bool!
     var strDay: String!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = strDay;
        self.tblView.reloadData()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
          return 3
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isSunday {
            let cell:StyleCell = tableView.dequeueReusableCell(withIdentifier: String(describing: StyleCell.self), for: indexPath) as? StyleCell ?? StyleCell()
            cell.lblTitle.text = ""
            cell.lblTitle.text = String("Open for Business ")
            cell.switchOptions.isOn = false;
            return cell

        } else {
            if indexPath.row==0 {
                let cell:StyleCell = tableView.dequeueReusableCell(withIdentifier: String(describing: StyleCell.self), for: indexPath) as? StyleCell ?? StyleCell()
                cell.lblTitle.text = ""
                if indexPath.section == 0 {
                    cell.lblTitle.text = String("Open for Business")
                }else if indexPath.section == 1 {
                    cell.lblTitle.text = String("Custom")
                }else if indexPath.section == 2 {
                    cell.lblTitle.text = String("Same Day Service")
                }
                    
                else if indexPath.section == 3 {
                    cell.lblTitle.text = String("Next Day Service")
                }
                return cell
                
            }else{
                let cell:SettingsCell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath) as? SettingsCell ?? SettingsCell()
                cell.lblTitle.text = ""
                cell.lblSubTitle.text = ""
                
                if indexPath.section == 0 {
                    if indexPath.row == 1{
                        cell.lblTitle.text = String("Open")
                        cell.lblSubTitle.text = String("9:00 AM")
                    }
                    else if indexPath.row == 2{
                        cell.lblTitle.text = String("Close")
                        cell.lblSubTitle.text = String("10:00 PM")
                    }
                }
                if indexPath.section == 1 {
                    if indexPath.row == 1{
                        cell.lblTitle.text = String("Begin Deliveries")
                        cell.lblSubTitle.text = String("10:00 AM")
                    }
                    else if indexPath.row == 2{
                        cell.lblTitle.text = String("End Deliveries")
                        cell.lblSubTitle.text = String("11:00 PM")
                    }
                }
                if indexPath.section == 2 {
                    if indexPath.row == 1{
                        cell.lblTitle.text = String("Upcharge")
                        cell.lblSubTitle.text = String("$9.99")
                    }
                    else if indexPath.row == 2{
                        cell.lblTitle.text = String("Cutoff")
                        cell.lblSubTitle.text = String("9:00 AM")
                    }
                }
                if indexPath.section == 3 {
                    if indexPath.row == 1{
                        cell.lblTitle.text = String("Upcharge")
                        cell.lblSubTitle.text = String("$4.99")
                    }
                    else if indexPath.row == 2{
                        cell.lblTitle.text = String("Cutoff")
                        cell.lblSubTitle.text = String("6:00 PM")
                    }
                }
                return cell
                
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
        }else if indexPath.section == 1 {
            
        }else if indexPath.section == 2 {
            
        }
    }
}

//
//  ContactInfoViewController.swift
//  DemoTableView
//
//  Created by Apple on 13/04/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ContactInfoCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInput: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblTitle.font = UIFont.systemFont(ofSize: 15)
    }
}

class ContactInfoViewController: UIViewController {
    @IBOutlet weak var tblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      //  navigationController?.navigationBar.barTintColor = UIColor(red: 1.0/255.0, green: 180.0/255.0, blue: 208.0/255.0, alpha: 1.0)
        
    }
}

extension ContactInfoViewController:UITableViewDelegate, UITableViewDataSource {
    
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
            if indexPath.row == 0 {
                cell.lblTitle.text = String("Phone")
                cell.lblInput.text = String("(000) 000-0000")
            }else if indexPath.row == 1 {
                cell.lblTitle.text = String("SMS")
                cell.lblInput.text = String("(000) 000-0000")
            }else if indexPath.row == 2 {
                cell.lblTitle.text = String("Email")
                cell.lblInput.text = String("email@email.com")
            }
            return cell
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

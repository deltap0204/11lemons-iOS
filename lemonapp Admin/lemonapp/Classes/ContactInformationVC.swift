//
//  ContactInformationVC.swift
//  lemonapp
//
//  Created by David Bucci on 12/04/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//

import UIKit

class ContactInformationVC: UIViewController {

    @IBOutlet weak var tblContact: UITableView!
    
    
     let contArr = [["title":"PHONE","info":"0123456789"],["title":"SMS","info":"01"],["title":" EMAIL","info":"abc@gmail.com"]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

}
extension ContactInformationVC : UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 54
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactInfoCell", for: indexPath) as! contactInfoCell
        
        let dictObj = contArr[indexPath.row] as NSDictionary
        cell.lblinfo.text = (dictObj["info"] as! String)
        cell.lblname.text = (dictObj["title"] as! String)
        
      
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
}


class  contactInfoCell: UITableViewCell{
   
    
    @IBOutlet weak var lblinfo: UILabel!
    @IBOutlet weak var lblname: UILabel!
}

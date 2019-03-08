//
//  PickAttributeCategoryViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit

class PickAttributeCategoryViewController: UITableViewController {

    var pickedCategory: ((_ category: Category) -> ())?
    var orderDetail: OrderDetail?    
    var router: NewOrderRouter?
    
    var dataModel = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = LemonAPI.getAttributeCategories().request().observeNext { [weak self] (result: EventResolver<[Category]>) in
            do {
                let orders = try result()
                
                self?.dataModel = []
                orders.forEach {
                    self?.dataModel.append($0)
                }
                self?.tableView?.reloadData()
            } catch { }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rawCell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")
        let cell = rawCell as? PickAttributeCategoryViewCell ?? PickAttributeCategoryViewCell(style: .default, reuseIdentifier: "categoryCell")
        
        cell.category = dataModel[indexPath.row]
        cell.lblTitle?.text = dataModel[indexPath.row].name
        cell.lblDescription?.text = dataModel[indexPath.row].description

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.pickedCategory?(dataModel[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }

}

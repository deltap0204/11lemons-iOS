//
//  NewService.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond
import MBProgressHUD

class NewServiceViewController: CreationBaseVC {
    
    @IBOutlet fileprivate weak var doneBtn: UIBarButtonItem!
    @IBOutlet fileprivate weak var cancelBtn: UIBarButtonItem!
    
    var department: Service?
    var newService: Service = Service(id: 0)
    
    fileprivate var txtList:[UITextField] = []
    fileprivate var imgNormalHasBeenChanged = false
    fileprivate var imgNormalToUpload: UIImage?
    fileprivate var imgSelectedHasBeenChanged = false
    fileprivate var imgSelectedToUpload: UIImage?
    fileprivate var isNormalImageUpdated = true
    fileprivate var isSelectedImageUpdated = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.isEnabled = true
        self.scrollView.addGestureRecognizer(gestureRecognizer)
        
        if let department = department {
            title = department.name
        }
        
        addViewToScrollView(initGeneralPrefs())
        addViewToScrollView(initUnitTypePrefs())
        addViewToScrollView(initIconsPrefs())
        addViewToScrollView(initActivePrefs())
        
        if isEditMode {
            addViewToScrollView(initDeletePrefs())
        }
        
        navigationItem.rightBarButtonItems = [doneBtn]
        navigationItem.leftBarButtonItems = [cancelBtn]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.navigationController as? YellowNavigationController)?.barStyle.value = .blue
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (self.navigationController as? YellowNavigationController)?.barStyle.value = .yellow
    }
    
    fileprivate func initGeneralPrefs() -> UIView {
        let nameRow = PreferencesRow(isRowWithSwitch: false, title: "Name", value: isEditMode ? newService.name : "")
        self.txtList.append(nameRow.txtValue)
        nameRow.txtValue.placeholder = "Name"
        
        nameRow.onTextValueChanged = {[weak self] textField in
            self?.newService.name = textField.text ?? ""
        }
        
        nameRow.onTextValueIsChanging = {[weak self] textField in
            self?.newService.name = textField.text ?? ""
        }
        
        let priceRow = PreferencesRow(isRowWithSwitch: false, title: "Base Price", value: isEditMode ? "$" + String(format: "%.2f", newService.price) : "")
        self.txtList.append(priceRow.txtValue)
        priceRow.txtValue.placeholder = "Price"
        priceRow.txtValue.keyboardType = .decimalPad
        priceRow.onTextValueChanged = {[weak self] textField in
            let text = textField.text ?? ""
            let priceDecimal = Double(text.replacingOccurrences(of: "$", with: "") ) ?? 0.0
            priceRow.txtValue.text = "$" + String(format: "%.2f", priceDecimal)
            self?.newService.price = priceDecimal ?? 0.0
        }
        
        priceRow.onTextValueIsChanging = {[weak self] textField in
            let text = textField.text ?? ""
            let priceDecimal = Double(text.replacingOccurrences(of: "$", with: "") ) ?? 0.0
            self?.newService.price = priceDecimal ?? 0.0
        }
        
        return PreferencesView(rows: [nameRow, priceRow], title: "GENERAL INFO")
    }
    
    fileprivate func initUnitTypePrefs() -> UIView {
        
        let prefView = PreferencesView(rows: [
            PreferencesRow(rowWithTick: "Piece", isSwitchOn: false),
            PreferencesRow(rowWithTick: "Item", isSwitchOn: false),
            PreferencesRow(rowWithTick: "Pound", isSwitchOn: false),
            PreferencesRow(rowWithTick: "Month", isSwitchOn: false),
            PreferencesRow(rowWithTick: "Hour", isSwitchOn: false),
            PreferencesRow(rowWithTick: "Other", isSwitchOn: false)
            ], title: "UNIT TYPE - SELECT ONE")
        if isEditMode {
            prefView.rows.filter{
                if let rowPreference = $0 as? PreferencesRow {
                    return rowPreference.isRowWithTick
                }
                return false
                 }.forEach {
                    if let rowPreference = $0 as? PreferencesRow {
                        if rowPreference.lblTitle.text! == self.newService.unitType {
                                rowPreference.setSelected(true)
                        }
                    }
            }
        }
        
        prefView.rows.filter{
            if let rowPreference = $0 as? PreferencesRow {
                return rowPreference.isRowWithTick
            }
            return false
            }.forEach { row in
                if let rowPreference = row as? PreferencesRow {
                    rowPreference.secondaryView.bnd_controlEvent(UIControlEvents.touchUpInside).observeNext { [weak self] e in
                     
                //rowPreference.secondaryView.bnd_controlEvent.filter { $0 == UIControlEvents.touchUpInside } .observeNext { [weak self] e in
                    prefView.rows.filter{
                        if let rowPreference = $0 as? PreferencesRow {
                            return rowPreference.isRowWithTick
                        }
                        return false }.forEach {
                        if let rowPreference = $0 as? PreferencesRow {
                            rowPreference.setSelected(false)
                        }
                    }
                    rowPreference.setSelected(!rowPreference.isSelected)
                    self?.newService.unitType = rowPreference.lblTitle.text!
                }
                }
        }
        
        return prefView
    }

    fileprivate func initIconsPrefs() -> UIView {
        let view = UploadIconsView(viewController: self, imageNormalURL: isEditMode ? newService.inactiveImage : nil, imageSelectedURL: isEditMode ? newService.activeImage : nil, buttonTitle: "Service")
        view.onSelectClosure = { [weak self] image, isNormalImage in
            guard let strongSelf = self else { return }
            strongSelf.saveImage(image, isNormalImage: isNormalImage)
            
            if isNormalImage {
                strongSelf.imgNormalHasBeenChanged = true
                strongSelf.imgNormalToUpload = image
                strongSelf.isNormalImageUpdated = false
            } else {
                strongSelf.imgSelectedHasBeenChanged = true
                strongSelf.imgSelectedToUpload = image
                strongSelf.isSelectedImageUpdated = false
            }
        }
        return view
    }
  
    fileprivate func initActivePrefs() -> UIView {
        let activeRow = PreferencesRow(isRowWithSwitch: true, title: "Active Product", isSwitchOn: isEditMode ? newService.active : true)
        newService.active = true
        activeRow.switchValue.bnd_on.observeNext { [weak self] status in
            self?.newService.active = status
        }
        return PreferencesView(rows: [activeRow], title: "", description: "When turned ON, this will be visibile to Customers in the Pricing Screen of their app." )
    }

    fileprivate func initDeletePrefs() -> UIView {
        return DeleteView(deleteBtnTitle: "Delete Service") {
            self.showDeleteConfirmation()
        }
    }

    
    fileprivate func saveImage(_ img: UIImage?, isNormalImage: Bool) {
        if let photo = img {
            ImageCache.saveImage(photo, url: "service_picture").observeNext {
                if let fileURL = $0() {
                    _ = LemonAPI.uploadDepartmentImage(imgURL: fileURL)
                        .request().observeNext { (resultResolver: EventResolver<String>) in
                            do {
                                let departmentPicture = try resultResolver()
                                if isNormalImage {
                                    self.newService.inactiveImage = departmentPicture
                                    self.isNormalImageUpdated = true
                                } else {
                                    self.newService.activeImage = departmentPicture
                                    self.isSelectedImageUpdated = true
                                }
                                print(departmentPicture)
                            } catch let error {
                            }
                    }
                }
            }
        }
    }
    
    fileprivate func showDeleteConfirmation() {
        let alert = UIAlertController(title: "Are you sure want to delete this?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete Service", style: .destructive, handler: { _ in
            self.deleteService()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func deleteService() {
        let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        progress.label.text = "Deleting"
        _ = LemonAPI.deleteService(serviceID: newService.id).request().observeNext { [weak self] (_: EventResolver<String>) in
            progress.hide(animated: true)
            guard let strongSelf = self else { return }
            strongSelf.successAndBack()
        }
    }
    
    fileprivate func validation() -> Bool {
        guard department != nil else { return false }
        let serviceCategoryPlaceholder = Service(id: 0)
        guard !newService.name.isEmpty && newService.name != serviceCategoryPlaceholder.name  else { return false }
        
        guard !newService.unitType.isEmpty && newService.unitType != serviceCategoryPlaceholder.unitType else { return false }
        
        return true
    }
    
    @IBAction func didDoneButtonPressed(_ sender: AnyObject) {
        guard validation() else {
            let alertController = UIAlertController(title: "", message: "Please, complete all fields", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if isSelectedImageUpdated && isNormalImageUpdated {
            let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
            if isEditMode {
                _ = LemonAPI.updateServices(service: newService).request().observeNext { [weak self] (_: EventResolver<String>) in
                    progress.hide(animated: true)
                    guard let strongSelf = self else { return }
                    strongSelf.successAndBack()
                    }
            } else {
                newService.parentID = department!.id
                _ = LemonAPI.createService(service: newService).request().observeNext { [weak self] (_: EventResolver<String>) in
                    progress.hide(animated: true)
                    guard let strongSelf = self else { return }
                    strongSelf.successAndBack()
                }
            }
        } else {
            //TODO: show pop up warning to waite picture will be upload
        }
    }
    
    fileprivate func showCustomeAlert(_ title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { _ in
            alert.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(_ sender: UITapGestureRecognizer) {
        self.txtList.forEach { txtView in
            txtView.resignFirstResponder()
        }
    }
}

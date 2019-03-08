//
//  NewAttributeCategoryViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond
import MBProgressHUD

class NewAttributeCategoryViewController : CreationBaseVC {

    @IBOutlet fileprivate weak var btnDone: UIBarButtonItem!
    @IBOutlet fileprivate weak var btnCancel: UIBarButtonItem!
    
    fileprivate var txtList:[UITextField] = []
    
    var attributeCategory: Category?
    
    var viewModel: NewAttributeCategoryViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = NewAttributeCategoryViewModel(attributeCategory: attributeCategory, isEditMode: isEditMode, delegate: self)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.isEnabled = true
        self.scrollView.addGestureRecognizer(gestureRecognizer)

        viewModel.isBusy.observeNext { [weak self] isBusy in
            guard let strongSelf = self else { return }
            
            if isBusy {
                MBProgressHUD.showAdded(to: strongSelf.view, animated: true)
            } else {
                MBProgressHUD.hide(for: strongSelf.view, animated: true)
            }
        }
        var titleScreen = "New Attribute"
        
        addViewToScrollView(initGeneralPrefs())
        addViewToScrollView(initCategorySettingsPrefs())
        addViewToScrollView(initMultipleValues())
        addViewToScrollView(initTemporary())
        addViewToScrollView(initServices())
        
        if isEditMode {
            titleScreen = attributeCategory!.name ?? "No Name"
            self.addViewToScrollView(initDeletePrefs())
        }
        
        self.title = titleScreen
        navigationItem.rightBarButtonItems = [btnDone]
        navigationItem.leftBarButtonItems = [btnCancel]
    }
    
    fileprivate func initGeneralPrefs() -> UIView {
        let nameRow = PreferencesRow(isRowWithSwitch: false, title: "Name", value: viewModel.getName())
        self.txtList.append(nameRow.txtValue)
        nameRow.txtValue.placeholder = "Attribute"
        
        nameRow.onTextValueChanged = {[weak self] textField in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.setName(textField.text)
        }
        nameRow.onTextValueIsChanging = {[weak self] textField in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.setName(textField.text)
        }
        
        return PreferencesView(rows: [nameRow], title: "")
    }
    
    fileprivate func initCategorySettingsPrefs() -> UIView {
        
        let itemizeRow = PreferencesRow(isRowWithSwitch: true, title: "Itemize on Receipt", isSwitchOn: viewModel.getItemizeOnReceipt())
        itemizeRow.switchValue.bnd_on.observeNext { [weak self] status in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.setItemizeOnReceipt(status)
        }
        
        
        let reqInputRow = PreferencesRow(isRowWithSwitch: true, title: "Require Input", isSwitchOn: viewModel.getRequired())
        reqInputRow.switchValue.bnd_on.observeNext { [weak self] status in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.setRequired(status)
        }
        
        return PreferencesView(rows: [reqInputRow, itemizeRow], title: "SETTINGS", description: "When turned ON, this attribute will be listed on the Customer's receipt (eg Brand, Colors).")
    }
    
    fileprivate func initMultipleValues() -> UIView {
        
        let multipleItemsRow = PreferencesRow(isRowWithSwitch: true, title: "Allow Multiple Values", isSwitchOn: viewModel.getAllowMultiple())
        
        
        multipleItemsRow.switchValue.bnd_on.observeNext { [weak self] status in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.setAllowMultiple(status)
        }
        return PreferencesView(rows: [multipleItemsRow], title: "", description: "When turned ON, users will be able to select multiple values (eg Color-blue, black, white).")
    }

    fileprivate func initTemporary() -> UIView {
        
        let tempAttrRow = PreferencesRow(isRowWithSwitch: true, title: "Temporary Attribute", isSwitchOn: viewModel.getTemporaryAttribute())
        tempAttrRow.switchValue.bnd_on.observeNext { [weak self] status in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.setTemporaryAttribute(status)
        }
        
        return PreferencesView(rows: [tempAttrRow], title: "", description: "Temporary Attributes are single use only. They will not be saved for subsequent orders (eg Repairs).")
    }
    
    fileprivate func initServices() -> UIView {
        viewModel.serviceRow =  ServiceSelectedView(title: "Services") {
            self.viewModel.selectServices()
        }
        return PreferencesView(rows: [viewModel.serviceRow!], title: "APPLICABLE SERVICES", description: "Select all the Services this Category applies to.")
    }
    
    
    fileprivate func initDeletePrefs() -> UIView {
        return DeleteView(deleteBtnTitle: "Delete Attribute") {
            self.viewModel.onDelete()
        }
    }

    @IBAction func didDoneButtonPressed(_ sender: AnyObject) {
        viewModel.submitCategory()
    }
    
    @objc func hideKeyboard(_ sender: UITapGestureRecognizer) {
        self.txtList.forEach { txtView in
            txtView.resignFirstResponder()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let departmentVC = segue.destination as? DepartmentSelectionViewController {
            departmentVC.viewModel = DepartmentSelectionViewModel(delegate: departmentVC, selectionDelegate: viewModel, serviceSelected: viewModel.servicesRelated)
        }
    }
}

extension NewAttributeCategoryViewController: NewAttributeCategoryViewModelDelegate {
    func showAlert(_ alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
    
    func goBackSeccefully() {
        successAndBack()
    }
    
    func segue(_ name:String) {
        performSegue(withIdentifier: name, sender: nil)
    }
}

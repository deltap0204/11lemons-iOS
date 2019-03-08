//
//  NewAttributeViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bolts
import MBProgressHUD

class NewAttributeViewController : CreationBaseVC {
    
    @IBOutlet fileprivate weak var btnDone: UIBarButtonItem!
    @IBOutlet fileprivate weak var btnCancel: UIBarButtonItem!
    fileprivate var txtList:[UITextField] = []
    
    var category: Category?
    var attribute: Attribute = Attribute(id: 0)

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
        
        
        if let category = self.category {
            attribute.categoryId = category.id
            attribute.attributeCategory = category.name
        }
        var titleScreen = "New"
        if let category = self.category {
            titleScreen = "\(titleScreen) \(category.name)"
        }
            
        addViewToScrollView(initGeneralPrefs())
        addViewToScrollView(initUpchargePrefs())
        addViewToScrollView(initIconsPrefs())
        if isEditMode {
            titleScreen = attribute.attributeName
            self.addViewToScrollView(initDeletePrefs())
        }
        
        self.title = titleScreen
        navigationItem.rightBarButtonItems = [btnDone]
        navigationItem.leftBarButtonItems = [btnCancel]
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
        let nameRow = PreferencesRow(isRowWithSwitch: false, title: "Name", value: isEditMode ? attribute.attributeName : "")
        
        nameRow.txtValue.placeholder = "Attribute"
        
        self.txtList.append(nameRow.txtValue)
        nameRow.onTextValueChanged = {[weak self] textField in
            self?.attribute.attributeName = textField.text ?? ""
        }
        nameRow.onTextValueIsChanging = {[weak self] textField in
            self?.attribute.attributeName = textField.text ?? ""
        }
        
        return PreferencesView(rows: [nameRow], title: "GENERAL INFO")
    }
    
    fileprivate func initUpchargePrefs() -> UIView {
        let upchargeRow = PreferencesRow(isRowWithSwitch: true, title: "Upcharge", isSwitchOn: isEditMode ? attribute.upcharge : false)
        upchargeRow.switchValue.bnd_on.observeNext { [weak self] status in
            self?.attribute.upcharge = status
        }
        
        
        let upchargePriceRow = PreferencesRow(isRowWithSwitch: false, title: "Upcharge Price", value: isEditMode ? String(format: "%.2f", attribute.upchargeAmount) : "$0.0")
        self.txtList.append(upchargePriceRow.txtValue)
        upchargePriceRow.txtValue.placeholder = "$0.0"
        upchargePriceRow.txtValue.keyboardType = .decimalPad
        upchargePriceRow.onTextValueChanged = {[weak self] textField in
            let text = textField.text ?? ""
            let priceDecimal = Double(text.replacingOccurrences(of: "$", with: "") ) ?? 0.0
            upchargePriceRow.txtValue.text = "$" + String(format: "%.2f", priceDecimal)
            self?.attribute.upchargeAmount = priceDecimal
        }
        upchargePriceRow.onTextValueIsChanging = {[weak self] textField in
            let text = textField.text ?? ""
            let priceDecimal = Double(text.replacingOccurrences(of: "$", with: "") ) ?? 0.0
            self?.attribute.upchargeAmount = priceDecimal
        }
        
        
        let upchargeMarkupRow = PreferencesRow(isRowWithSwitch: false, title: "Upcharge Amount", value: isEditMode ? "\(attribute.upchargeMarkup)%" : "")
        self.txtList.append(upchargeMarkupRow.txtValue)
        upchargeMarkupRow.txtValue.placeholder = "0%"
        upchargeMarkupRow.txtValue.keyboardType = .decimalPad
        upchargeMarkupRow.onTextValueChanged = {[weak self] textField in
            let text = textField.text ?? ""
            let priceDecimal = Double(text.replacingOccurrences(of: "%", with: "") ) ?? 0.0
            upchargeMarkupRow.txtValue.text = String(format: "%.2f", priceDecimal) + "%"
            self?.attribute.upchargeMarkup = priceDecimal
        }
        
        upchargeMarkupRow.onTextValueIsChanging = {[weak self] textField in
            let text = textField.text ?? ""
            let priceDecimal = Double(text.replacingOccurrences(of: "%", with: "") ) ?? 0.0
            self?.attribute.upchargeMarkup = priceDecimal
        }
        
        return PreferencesView(rows: [upchargeRow, upchargePriceRow, upchargeMarkupRow], title: "UPCHARGES")
    }
    
    fileprivate func initIconsPrefs() -> UIView {
        let view = UploadIconsView(viewController: self, imageNormalURL: isEditMode ? attribute.inactiveImage : nil, imageSelectedURL: isEditMode ? attribute.activeImage : nil, buttonTitle: "Attribute")
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
    
    fileprivate func saveImage(_ img: UIImage?, isNormalImage: Bool) {
        if let photo = img {
            ImageCache.saveImage(photo, url: "attribute_picture").observeNext {
                if let fileURL = $0() {
                    _ = LemonAPI.uploadDepartmentImage(imgURL: fileURL)
                        .request().observeNext { (resultResolver: EventResolver<String>) in
                            do {
                                let departmentPicture = try resultResolver()
                                if isNormalImage {
                                    self.attribute.inactiveImage = departmentPicture
                                    self.isNormalImageUpdated = true
                                } else {
                                    self.attribute.activeImage = departmentPicture
                                    self.isSelectedImageUpdated = true
                                }
                                print(departmentPicture)
                            } catch _ {
                            }
                    }
                }
            }
        }
    }
    
    fileprivate func initDeletePrefs() -> UIView {
        return DeleteView(deleteBtnTitle: "Delete Attribute") {
            self.showDeleteConfirmation()
        }
    }
    
    fileprivate func showDeleteConfirmation() {
        let alert = UIAlertController(title: "Are you sure want to delete this?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete Attribute", style: .destructive, handler: { _ in
            self.deleteAttribute()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func deleteAttribute() {
        let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        progress.label.text = "Deleting"

        _ = LemonAPI.deleteAttribute(attributeID: attribute.id).request().observeNext { [weak self] (_: EventResolver<String>) in
            progress.hide(animated: true)
            guard let strongSelf = self else { return }
            strongSelf.successAndBack()
        }
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
                _ = LemonAPI.updateAttribute(attribute: attribute).request().observeNext { [weak self] (result: EventResolver<Attribute>) in
                    progress.hide(animated: true)
                    guard let strongSelf = self else { return }
                    strongSelf.successAndBack()
                }
            } else {
                _ = LemonAPI.createAttribute(attribute: attribute).request().observeNext { [weak self] (result: EventResolver<Attribute>) in
                    progress.hide(animated: true)
                    guard let strongSelf = self else { return }
                    strongSelf.successAndBack()
                }
            }
        } else {
            //showCustomeAlert("The images are uploading, please try again.")
        }
    }
    
    fileprivate func validation() -> Bool {
        let attributePlaceholder = Attribute(id: 0)
        guard !attribute.attributeName.isEmpty && attribute.attributeName != attributePlaceholder.attributeName  else { return false }
        
        return true
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

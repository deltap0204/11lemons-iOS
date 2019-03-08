//
//  NewServiceCategoryViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond
import MBProgressHUD

class NewServiceCategoryViewController: CreationBaseVC {

    var department: Service = Service(id: 0)
    fileprivate var txtList:[UITextField] = []

    var viewModel: NewDepartmentViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = NewDepartmentViewModel(department: department, isEditMode: isEditMode, delegate: self)
        yPosition = -5
        
        addKeyboardLogic()
        
        addViewToScrollView(initGeneralPrefs())
        addViewToScrollView(initPriceRoundingPrefs())
        addViewToScrollView(initActivePrefs())
        addViewToScrollView(initBetaPrefs())
        addViewToScrollView(initSalesTaxPrefs())
        addViewToScrollView(initIconsPrefs())
        if viewModel.isEditMode {
            addViewToScrollView(initDeletePrefs())
            self.title = viewModel.department.name
        }
        
        viewModel.isBusy.observeNext { [weak self] isBusy in
            guard let strongSelf = self else { return }
            if isBusy {
                MBProgressHUD.showAdded(to: strongSelf.view, animated: true)
            } else {
                MBProgressHUD.hide(for: strongSelf.view, animated: true)
            }
        }
    }
    
    fileprivate func addKeyboardLogic() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.isEnabled = true
        self.scrollView.addGestureRecognizer(gestureRecognizer)
    }
    
    fileprivate func initGeneralPrefs() -> UIView {
        let nameRow = PreferencesRow(isRowWithSwitch: false, title: "Name", value: viewModel.getName())
        self.txtList.append(nameRow.txtValue)
        nameRow.txtValue.placeholder = "Name"
        nameRow.onTextValueChanged = {[weak self] textField in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.setName( textField.text ?? "" )
        }
        
        nameRow.onTextValueIsChanging = {[weak self] textField in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.setName( textField.text ?? "" )
        }
        
        
        let descriptionRow = PreferencesRow(isRowWithSwitch: false, title: "Description", value: viewModel.getDescription())
        self.txtList.append(descriptionRow.txtValue)
        descriptionRow.txtValue.placeholder = "Description"
        descriptionRow.onTextValueChanged = {[weak self] textField in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.setDescription( textField.text ?? "" )
        }
        
        descriptionRow.onTextValueIsChanging = {[weak self] textField in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.setDescription( textField.text ?? "" )
        }
        
        return PreferencesView(rows: [nameRow, descriptionRow], title: "GENERAL INFO")
    }
    
    fileprivate func initPriceRoundingPrefs() -> UIView {
        let roundRow = PreferencesRow(isRowWithSwitch: true, title: "Round Price", isSwitchOn: viewModel.getRoundPrice())
        roundRow.switchValue.bnd_on.observeNext { [weak self] status in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.setRoundPrice(status)
        }
        
        let roundNearestRow = PreferencesRow(isRowWithSwitch: false, title: "Round to Nearest", value: viewModel.getPriceNearset())
        self.txtList.append(roundNearestRow.txtValue)
        roundNearestRow.txtValue.placeholder = "0.00"
        roundNearestRow.txtValue.keyboardType = UIKeyboardType.decimalPad
        
        roundNearestRow.onTextValueChanged = {[weak self] textField in
            guard let strongSelf = self else { return }
            let text = textField.text ?? ""
            let priceDecimal = Double(text) ?? 0.0
            roundNearestRow.txtValue.text = String(format: "%.2f", priceDecimal)
            strongSelf.viewModel.setPriceNearset(priceDecimal ?? 0.0)
        }
        
        roundNearestRow.onTextValueIsChanging = {[weak self] textField in
            guard let strongSelf = self else { return }
            let text = textField.text ?? ""
            let priceDecimal = Double(text) ?? 0.0
            strongSelf.viewModel.setPriceNearset(priceDecimal ?? 0.0)
        }
        
        return PreferencesView(rows: [roundRow, roundNearestRow], title: "PRICE ROUNDING")
    }
    
    fileprivate func initActivePrefs() -> UIView {
        let activeRow = PreferencesRow(isRowWithSwitch: true, title: "Active", isSwitchOn: viewModel.getIsActive())
        activeRow.switchValue.bnd_on.observeNext { [weak self] status in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.setIsActive(status)
        }
        return PreferencesView(rows: [activeRow], title: "", description: "When turned ON, this be visibile to Customers in the Pricing Screen of the app.")
    }
    
    fileprivate func initBetaPrefs() -> UIView {
        let betaRow = PreferencesRow(isRowWithSwitch: true, title: "Beta", isSwitchOn: viewModel.getIsBeta())
        betaRow.switchValue.bnd_on.observeNext { [weak self] status in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.setIsBeta(status)
        }
        return PreferencesView(rows: [betaRow], title: "", description: "When turned ON, department is visible to Beta Customers in the Pricing Screen of the app.")
    }
    
    fileprivate func initSalesTaxPrefs() -> UIView {
        let taxableRow = PreferencesRow(isRowWithSwitch: true, title: "Taxable", isSwitchOn: viewModel.getTaxable())
        taxableRow.switchValue.bnd_on.observeNext { [weak self] status in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.setTaxable(status)
        }
        
        
        let rateRow = PreferencesRow(isRowWithSwitch: false, title: "Rate", value: viewModel.getRate())
        self.txtList.append(rateRow.txtValue)
        rateRow.txtValue.placeholder = "0.00%"
        rateRow.txtValue.keyboardType = UIKeyboardType.decimalPad
        
        rateRow.onTextValueChanged = {[weak self] textField in
            guard let strongSelf = self else { return }
            let text = textField.text ?? ""
            let priceDecimal = Double(text.replacingOccurrences(of: "%", with: "") ) ?? 0.0
            rateRow.txtValue.text = String(format: "%.2f", priceDecimal) + "%"
            strongSelf.viewModel.setRate(priceDecimal)
        }
        
        rateRow.onTextValueIsChanging = {[weak self] textField in
            guard let strongSelf = self else { return }
            let text = textField.text ?? ""
            let priceDecimal = Double(text.replacingOccurrences(of: "%", with: "") ) ?? 0.0
            strongSelf.viewModel.setRate(priceDecimal)
        }
        
        rateRow.onTextValueIsChanging = {[weak self] textField in
            guard let strongSelf = self else { return }
            let text = textField.text ?? ""
            let priceDecimal = Double(text.replacingOccurrences(of: "%", with: "") ) ?? 0.0
            strongSelf.viewModel.setRate(priceDecimal)
        }
                
        return PreferencesView(rows: [taxableRow, rateRow], title: "SALES TAX")
    }
    
    fileprivate func initIconsPrefs() -> UIView {
        let view = UploadIconsView(viewController: self, imageNormalURL: viewModel.getInactiveImage(), imageSelectedURL: viewModel.getActiveImage())
        view.onSelectClosure = { [weak self] image, isNormalImage in
            guard let strongSelf = self else { return }
            
            strongSelf.viewModel.saveImage(image, isNormalImage: isNormalImage)
        }
        return view
    }
    
    fileprivate func initDeletePrefs() -> UIView {
        return DeleteView(deleteBtnTitle: "Delete") {
            self.viewModel.onDelete()
        }
    }
    
    @IBAction func didDoneButtonPressed(_ sender: AnyObject) {
        viewModel.onSubmite()
    }
    
    @objc func hideKeyboard(_ sender: UITapGestureRecognizer) {
        self.txtList.forEach { txtView in
            txtView.resignFirstResponder()
        }
    }
}

extension NewServiceCategoryViewController: NewDepartmentViewModelDelegate {
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

//
//  DetailedNewOrderViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond
import ReactiveKit

final class DetailedNewOrderViewController: UIViewController {
    
    @IBOutlet fileprivate weak var nextButton: UIButton!
    @IBOutlet var nextBtnHeight: NSLayoutConstraint!
    
    @IBOutlet var titleView: UIView!
    @IBOutlet var errorView: UIView!
    
    @IBOutlet fileprivate weak var washFoldButton: UIButton!
    @IBOutlet fileprivate weak var launderPressButton: UIButton!
    @IBOutlet fileprivate weak var dryCleanButton: UIButton!
    
    @IBOutlet fileprivate weak var tideIcon: UIView!
    @IBOutlet fileprivate weak var lblGarmentTitle: UILabel!
    @IBOutlet fileprivate weak var detergentRadioButtonGroup: RadioButtonGroup!
    @IBOutlet fileprivate weak var softenerRadioButtonGroup: RadioButtonGroup!
    @IBOutlet fileprivate weak var dryerRadioButtonGroup: RadioButtonGroup!
    @IBOutlet fileprivate weak var shirtsRadioButtonGroup: RadioButtonGroup!
    @IBOutlet fileprivate weak var tipsView: TipsView!
    
    @IBOutlet var circularButtons: [UIButton]!
    @IBOutlet var walletView: WalletView!
    @IBOutlet fileprivate weak var walletViewBottomSeparator: UIView!
    @IBOutlet var walletContainerStackView: UIStackView!
    @IBOutlet fileprivate weak var nextPickupView: NextPickupView!
    @IBOutlet fileprivate weak var nextPickupViewContainer: UIView!
    @IBOutlet fileprivate weak var nextPickupViewSeparator: UIView!
    
    fileprivate var timer: Timer?
    
    @IBOutlet fileprivate weak var orderDetailsButton: UIBarButtonItem!
    
    var router: NewOrderRouter?
    let disposeBag = DisposeBag()
    var viewModel: DetailedNewOrderViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    fileprivate var showError = false {
        didSet {
            titleView.isHidden = showError
            errorView.isHidden = !showError
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: nextBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: nextButton)

        setLemonBackground()
        
        circularButtons.forEach { $0.centerImageAndTitle() }
        
        nextButton.bnd_tap.observeNext { [weak self] in
            guard let viewModel = self?.viewModel else { return }
            
            if viewModel.anyServiceTypeSelected() != true {
                self?.showError = true
                return
            }
            
            self?.performSegueWithIdentifier(.Delivery)
        }.dispose(in:self.disposeBag)
        /*
        [washFoldButton, launderPressButton, dryCleanButton].forEach { button in
            button.bnd_tap.observeNext { _ in
                button?.bnd_selected.next(!button.isSelected)
                
            }
        }
 */
        
        if navigationController?.viewControllers.count == 1 {
            let cancel = UIButton(frame: CGRect(x: 0, y: 0, width: 14, height: 13))
            cancel.setImage(UIImage(named: "ic_cancel"), for: UIControlState())
            cancel.bnd_tap.observeNext { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }.dispose(in:self.disposeBag)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancel)
        }
        
        bindViewModel()
    }
    
    fileprivate func bindViewModel() {
        guard let viewModel = viewModel, isViewLoaded else { return }
        
        viewModel.washFoldSelected.bind(to: washFoldButton.bnd_selected)
        //washFoldButton.bnd_selected.bind(to: viewModel.washFoldSelected)
        
        viewModel.launderPressSelected.bind(to: launderPressButton.bnd_selected)
        //launderPressButton.bnd_selected.bind(to: viewModel.launderPressSelected)
        
        viewModel.dryCleanSelected.bind(to: dryCleanButton.bnd_selected)
        //dryCleanButton.bnd_selected.bind(to: viewModel.dryCleanSelected)
        
        washFoldButton.bnd_tap.observeNext { _ in
            viewModel.washFoldSelected.next(!self.washFoldButton.isSelected)
            
        }.dispose(in:self.disposeBag)
        launderPressButton.bnd_tap.observeNext { _ in
            viewModel.launderPressSelected.next(!self.launderPressButton.isSelected)
            
        }.dispose(in:self.disposeBag)
        dryCleanButton.bnd_tap.observeNext { _ in
            viewModel.dryCleanSelected.next(!self.dryCleanButton.isSelected)
            
        }.dispose(in:self.disposeBag)
        
        viewModel.selectedDetergent.map { viewModel.detergents.index(of: $0)! }.bind(to: detergentRadioButtonGroup.selectedValueIndex).dispose(in:self.disposeBag)
        detergentRadioButtonGroup.selectedValueIndex.map {viewModel.detergents[$0] }.bind(to: viewModel.selectedDetergent).dispose(in:self.disposeBag)
        detergentRadioButtonGroup.selectedValueIndex.observeNext { [weak self] (index) in
            self?.tideIcon.borderColor = self?.detergentRadioButtonGroup.buttons![index].borderColor ?? UIColor.clear
        }.dispose(in:self.disposeBag)
        
        viewModel.selectedSoftener.map { viewModel.softeners.index(of: $0)! }.bind(to: softenerRadioButtonGroup.selectedValueIndex).dispose(in:self.disposeBag)
        softenerRadioButtonGroup.selectedValueIndex.map {viewModel.softeners[$0] }.bind(to: viewModel.selectedSoftener).dispose(in:self.disposeBag)
        
        viewModel.selectedDryer.map { viewModel.dryers.index(of: $0)! }.bind(to: dryerRadioButtonGroup.selectedValueIndex).dispose(in:self.disposeBag)
        dryerRadioButtonGroup.selectedValueIndex.map { viewModel.dryers[$0] }.bind(to: viewModel.selectedDryer).dispose(in:self.disposeBag)
        
        viewModel.selectedShirt.map { viewModel.shirts.index(of: $0)! }.bind(to: shirtsRadioButtonGroup.selectedValueIndex).dispose(in:self.disposeBag)
        shirtsRadioButtonGroup.selectedValueIndex.map { viewModel.shirts[$0] }.bind(to: viewModel.selectedShirt).dispose(in:self.disposeBag)
        shirtsRadioButtonGroup.valueTitles = viewModel.shirts.map { $0.rawValue }
        
        tipsView.toolbarDelegate = self
        tipsView.pickerDelegate = self
        tipsView.pickerDataSource = self
        tipsView.selectedTextRange = nil
        viewModel.selectedTips.observeNext {[weak self] in
            let percentString = String.init(format: "%d%%", $0)
            self?.tipsView.text = percentString
            if let index = self?.viewModel!.tipsValues.index(of: percentString) {
                self?.tipsView.setPickerSelection(index, component: 0, animated: false)
            }
        }.dispose(in:self.disposeBag)
        
        combineLatest(viewModel.washFoldSelected, viewModel.launderPressSelected, viewModel.dryCleanSelected).observeNext { [weak self ]_ in
            if self?.viewModel?.anyServiceTypeSelected() == true {
                self?.showError = false
            }
        }.dispose(in:self.disposeBag)
 
        
        viewModel.walletViewModel.observeNext { [weak self] in
            self?.walletView.viewModel = $0
        }.dispose(in:self.disposeBag)
        
        DataProvider.sharedInstance.pickupETA.bind(to: viewModel.pickupETA)
        
        viewModel.pickupETA.observeNext { [weak self] (value) in
            let date = Date().pickupShift(value)
            self?.nextPickupView.setTitle(date.timeHM(), subtitle: date.amPm())
        }.dispose(in:self.disposeBag)
        
        viewModel.userWalletBalance.observeNext { [weak self](amount) in
            var walletAmountHidden = true
            if let amount = amount {
                walletAmountHidden = !(amount > 0)
            }
            self?.walletView.isHidden = walletAmountHidden
            self?.walletViewBottomSeparator.isHidden = !walletAmountHidden
            self?.nextPickupViewContainer.backgroundColor = walletAmountHidden ? UIColor.lemonColor() : UIColor.clear
            self?.nextPickupViewContainer.isHidden = !walletAmountHidden
        }.dispose(in:self.disposeBag)
        
        self.title = viewModel.editMode ? "Edit Order" : "New Order"
        
        
        lblGarmentTitle.text = "PACKAGING"
        self.orderDetailsButton.isEnabled = false
        self.orderDetailsButton.tintColor = UIColor.clear
        self.orderDetailsButton.target = self
        self.orderDetailsButton.action = #selector(DetailedNewOrderViewController.didOrderDetailsButtonClicked(_:))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nextButton.fixForwardArrow()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? DeliveryViewController {
            viewController.viewModel = viewModel?.deliveryViewModel
            viewController.router = router
        } else if let viewController = segue.destination as? CommonContainerViewController {
            viewController.viewModel = self.viewModel?.commonContainerViewModel
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.refresh()
        showError = false
        
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.forsePickupETAUpdate), userInfo: nil, repeats: true)
        
        nextPickupView.startAnimation()
    }
    
    @objc fileprivate func forsePickupETAUpdate() {
        viewModel?.pickupETA.next((viewModel?.pickupETA.value)!)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
        
        nextPickupView.stopAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        title = "Services"
    }
    
    override func onExit() {
        viewModel?.resetOrder()
    }
    
    @objc func didOrderDetailsButtonClicked(_ sender: AnyObject?) {
    }
}

extension DetailedNewOrderViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel!.tipsValues[row]
    }
}

extension DetailedNewOrderViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel!.tipsValues.count
    }
}

extension DetailedNewOrderViewController: TextFieldWithPickerDelegate {
    func doneButtonPressed(_ textField: UITextField) {
        let percentString = viewModel!.tipsValues[tipsView.getPickerSelectedValue(0)]
        let numberString = percentString.replacingOccurrences(of: "%", with: "") ?? "0"
        viewModel?.selectedTips.value = Int(numberString) ?? 0
    }
    
    func cancelButtonPressed(_ textField: UITextField) {
        let percentString = tipsView.text
        if let text = percentString, let index = viewModel!.tipsValues.index(of: text) {
            tipsView.setPickerSelection(index, component: 0, animated: false)
        }
    }
}

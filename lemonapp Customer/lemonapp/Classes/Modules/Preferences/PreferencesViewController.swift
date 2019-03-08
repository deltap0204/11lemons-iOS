//
//  PreferencesViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond
import DrawerController
import SnapKit


final class PreferencesViewController : UIViewController {
    
    @IBOutlet fileprivate weak var tideIcon: UIView!
    @IBOutlet fileprivate weak var detergentRadioButtonGroup: RadioButtonGroup!
    @IBOutlet fileprivate weak var softenerRadioButtonGroup: RadioButtonGroup!
    @IBOutlet fileprivate weak var dryerRadioButtonGroup: RadioButtonGroup!
    @IBOutlet fileprivate weak var shirtsRadioButtonGroup: RadioButtonGroup!
    @IBOutlet fileprivate weak var tipsView: TipsView!
    @IBOutlet fileprivate weak var notesTextView: UITextView!
    @IBOutlet fileprivate weak var notesHintLabel: UILabel!
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var pickupContainer: UIView!
    
    @IBOutlet fileprivate weak var weekdayPicker: WeekdayPicker!
    @IBOutlet fileprivate weak var frequencySlider: FrequencySlider!
    @IBOutlet fileprivate weak var frequencyDescriptionLabel: UILabel!
    @IBOutlet fileprivate weak var nextPickupButton: UIButton!

    @IBOutlet fileprivate weak var alertView: UIView!
    @IBOutlet fileprivate weak var alertButton: UIButton!
    
    @IBOutlet var doneBtn: HighlightedButton!
    @IBOutlet var doneBtnHeight: NSLayoutConstraint!
    
    var viewModel: PreferencesViewModel? {
        didSet {
            if let viewModel = viewModel {
                bindViewModel(viewModel)
            }
        }
    }

    var router: PreferencesRouter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBlurredLemonBackground()
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: doneBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: doneBtn)
        
        if let viewModel = viewModel {
            bindViewModel(viewModel)
        }
    }
    
    func bindViewModel(_ viewModel: PreferencesViewModel) {
        guard isViewLoaded else { return }
        
        viewModel.selectedDetergent.map { viewModel.detergents.index(of: $0)! }.bind(to: detergentRadioButtonGroup.selectedValueIndex)
        detergentRadioButtonGroup.selectedValueIndex.map {viewModel.detergents[$0] }.bind(to: viewModel.selectedDetergent)
        detergentRadioButtonGroup.selectedValueIndex.observeNext { [weak self] (index) in
            self?.tideIcon.borderColor = self?.detergentRadioButtonGroup.buttons![index].borderColor ?? UIColor.clear
        }
        
        viewModel.selectedSoftener.map { viewModel.softeners.index(of: $0)! }.bind(to: softenerRadioButtonGroup.selectedValueIndex)
        softenerRadioButtonGroup.selectedValueIndex.map {viewModel.softeners[$0] }.bind(to: viewModel.selectedSoftener)
        
        viewModel.selectedDryer.map { viewModel.dryers.index(of: $0)! }.bind(to: dryerRadioButtonGroup.selectedValueIndex)
        dryerRadioButtonGroup.selectedValueIndex.map { viewModel.dryers[$0] }.bind(to: viewModel.selectedDryer)
        
        viewModel.selectedShirt.map { viewModel.shirts.index(of: $0)! }.bind(to: shirtsRadioButtonGroup.selectedValueIndex)
        shirtsRadioButtonGroup.selectedValueIndex.map { viewModel.shirts[$0] }.bind(to: viewModel.selectedShirt)
        shirtsRadioButtonGroup.valueTitles = viewModel.shirts.map { $0.rawValue }
        
        viewModel.alertHidden.observeOn(.main).map { $0 }.bind(to: frequencySlider.bnd_enabled)
        viewModel.alertHidden.observeOn(.main).bind(to: alertView.bnd_hidden)
        viewModel.alertText.observeOn(.main).bind(to: alertButton.bnd_title)
        alertButton.bnd_tap.observeNext { [weak self] in
            if let segueId = viewModel.requiredInfoCreationSegue,
                let infoViewModel = viewModel.requiredInfoViewModel {
                    (self?.navigationController as? YellowNavigationController)?.barStyle.value = .transparent
                    self?.performSegueWithIdentifier(segueId, sender: infoViewModel)
            }
        }
        
        tipsView.pickerDataSource = self
        tipsView.pickerDelegate = self
        tipsView.toolbarDelegate = self
        tipsView.selectedTextRange = nil
        viewModel.selectedTips.observeNext {[weak self] in
            let percentString = String.init(format: "%d%%", $0)
            self?.tipsView.text = percentString
            if let index = self?.viewModel!.tipsValues.index(of: percentString) {
                self?.tipsView.setPickerSelection(index, component: 0, animated: false)
            }
        }
        
        viewModel.shouldHideNotesHint.map { [weak self] hide in
            if hide {
                return hide
            } else {
                let isTextViewInEditMode = self!.notesTextView.isFirstResponder
                if isTextViewInEditMode {
                    return true
                }
                return false
            }
            }.bind(to: notesHintLabel.bnd_hidden)
        viewModel.notes.bidirectionalBind(to: notesTextView.bnd_text)
        
        viewModel.frequency.bidirectionalBind(to: frequencySlider.frequency)
        viewModel.frequencyDescription.observeOn(.main).bind(to: frequencyDescriptionLabel.bnd_text)
        viewModel.frequencyDescriptionColor.observeOn(.main).bind(to: frequencyDescriptionLabel.bnd_textColor)
        viewModel.weekday.bidirectionalBind(to: weekdayPicker.selectedWeekday)
        viewModel.nextPickupTitle.observeOn(.main).bind(to: nextPickupButton.bnd_title)
        viewModel.nextPickupAlpha.observeOn(.main).map { CGFloat($0) }.bind(to: nextPickupButton.bnd_alpha)
    }

    
    @IBAction func showMenu() {
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: AnyObject?) {
        if let viewModel = viewModel {
            viewModel.save()
            router?.done()
        }
    }
    
    @IBAction func info() {
        let alert = UIAlertController(title: "Scheduled Pickups", message: "Automate your laundry with scheduled pickups. You’ll always still have the flexibility to order on-demand when you need it, or cancel a scheduled pickup when you don’t. Just pick your favorite day of the week and how often you need a pickup. We’ll handle the rest.  ", preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewModel = sender as? CommonContainerViewModel, let viewController = segue.destination as? CommonContainerViewController {
            viewController.viewModel = viewModel
        }
    }
}

extension PreferencesViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel!.tipsValues[row]
    }
}

extension PreferencesViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel!.tipsValues.count
    }
}

extension PreferencesViewController: TextFieldWithPickerDelegate {
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

extension PreferencesViewController: KeyboardListenerProtocol {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataProvider.sharedInstance.userWrapper?.refresh()
    }
    
    func getAboveKeyboardView() -> UIView? {
        return nil
    }
}


extension PreferencesViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.rangeOfCharacter(from: CharacterSet.newlines) == nil {
            return true
        }
        textView.resignFirstResponder()
        return false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        notesHintLabel.isHidden = true
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 240, right: 0)
        scrollView.scrollRectToVisible(notesTextView.superview!.frame, animated: true)        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        notesHintLabel.isHidden = notesTextView.text.count > 0
        scrollView.contentInset = UIEdgeInsets.zero
    }
}


extension PreferencesViewController: YellowNavigationControllerChild {
    
    func preferredBarStyle() -> NavigationBarStyle {
        return .yellow
    }
}

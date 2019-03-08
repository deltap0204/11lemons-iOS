//
//  TextFieldWithPicker.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit

@objc protocol TextFieldWithPickerDelegate {
    @objc optional func doneButtonPressed(_ textField: UITextField);
    @objc optional func cancelButtonPressed(_ textField: UITextField);
}

class TextFieldWithPicker: UITextField {
    
    var toolbarDelegate: TextFieldWithPickerDelegate? = nil
    var pickerDelegate: UIPickerViewDelegate? = nil {
        didSet {
            if let picker = self.inputView as? UIPickerView {
                picker.delegate = pickerDelegate;
            }
        }
    }
    var pickerDataSource: UIPickerViewDataSource? = nil {
        didSet {
            if let picker = self.inputView as? UIPickerView {
                picker.dataSource = pickerDataSource;
            }
        }
    }
    
    convenience init () {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    fileprivate func initialize() {
        //set the UIPickerView to UITextField
        let pickerView = UIPickerView()
        self.inputView = pickerView
        
        //set the UIToolbar to UITextField
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(TextFieldWithPicker.actionDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(TextFieldWithPicker.actionCancel))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        self.inputAccessoryView = toolbar
    }
    
    @objc func actionDone() {
        self.endEditing(true)
        toolbarDelegate?.doneButtonPressed?(self)
    }
    
    @objc func actionCancel() {
        self.endEditing(true)
        toolbarDelegate?.cancelButtonPressed?(self)
    }
    
    func getPickerSelectedValue(_ component: Int) -> Int {
        if let picker = self.inputView as? UIPickerView {
            return picker.selectedRow(inComponent: component)
        } else {
            return 0;
        }
    }
    
    func setPickerSelection(_ row: Int, component: Int, animated: Bool) {
        if let picker = self.inputView as? UIPickerView {
            picker.selectRow(row, inComponent: component, animated: animated)
        }
    }
}

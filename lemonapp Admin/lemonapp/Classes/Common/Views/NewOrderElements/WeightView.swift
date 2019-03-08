import Foundation
import UIKit

class WeightView: UIView {
    
    @IBOutlet fileprivate weak var lblTitle: UILabel!
    @IBOutlet fileprivate weak var tfWeight: UITextField!
    
    var temporaryText: String?
    var noteText: String {
        get {
            return tfWeight.text ?? ""
        }
        set(text) {
            tfWeight.text = text
        }
    }
    
    var onFinishEdit: ((_ lbs:Double?) -> ())?

    convenience init () {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    fileprivate func initialize() {
        if let view = Bundle.main.loadNibNamed("WeightView", owner: self, options: nil)![0] as? UIView {
            self.frame = CGRect(origin: self.frame.origin, size: view.frame.size)
            view.isUserInteractionEnabled = true
            self.addSubview(view)
        }
        tfWeight.placeholder = "0.0"
        addButtonsToKeyboard()
    }
    
    fileprivate func addButtonsToKeyboard()
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(WeightView.doneAction))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(WeightView.cancelAction))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        tfWeight.delegate = self
        tfWeight.inputAccessoryView = toolBar
    }
    
    func setFocus() {
        tfWeight.becomeFirstResponder()
    }
    
    @objc func doneAction()
    {
        tfWeight.resignFirstResponder()
        if let lbs = Double(tfWeight.text!) {
            tfWeight.text = String(format: "%.1f", lbs)
            onFinishEdit?(Double(tfWeight.text!))
        }
    }
    
    @objc func cancelAction()
    {
        tfWeight.resignFirstResponder()
        tfWeight.text = temporaryText
    }
    
    func setWeightText(weight: Double){
        tfWeight.text = String(format: "%.1f", weight)
    }
}

extension WeightView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        temporaryText = tfWeight.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        doneAction()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldString = textField.text ?? ("" as NSString) as String
        if let textRange = Range(range, in: oldString) {
            let candidate = oldString.replacingCharacters(in: textRange, with: string)
            let regex = try? NSRegularExpression(pattern: "^\\d{0,2}(\\.\\d?)?$", options: [])
            return regex?.firstMatch(in: candidate, options: [], range: NSRange(location: 0, length: candidate.count)) != nil
        }
        return true
    }
}

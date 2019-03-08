import Foundation
import UIKit

class PreferencesRow: UIView {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var secondaryView: UIControl!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet fileprivate weak var btnNext: UIButton!
    @IBOutlet fileprivate weak var lblValue: UILabel!
    @IBOutlet weak var switchValue: UISwitch!
    @IBOutlet fileprivate weak var separatorView: UIView!
    @IBOutlet var txtValue: UITextField!
    
    @IBOutlet weak var separatorConstraintLeft: NSLayoutConstraint!
    fileprivate(set) var isRowWithTick: Bool = false
    fileprivate(set) var isSelected: Bool = false
    var onTextValueChanged: ((_ sender:UITextField) -> ())?
    var onTextValueIsChanging: ((_ sender:UITextField) -> ())?
    
    convenience init(isRowWithSwitch: Bool = false, title: String = "", value: String = "") {
        self.init(frame: CGRect.zero, isRowWithSwitch: isRowWithSwitch, title: title, value: value)
    }
    
    convenience init(isRowWithSwitch: Bool = false, title: String = "", isSwitchOn: Bool = false) {
        self.init(frame: CGRect.zero, isRowWithSwitch: isRowWithSwitch, title: title, isSwitchOn: isSwitchOn)
    }
    
    convenience init(rowWithTick title: String = "", isSwitchOn: Bool = false) {
        self.init(frame: CGRect.zero, isRowWithSwitch: false, isRowWithTick: true, title: title, isSwitchOn: isSwitchOn)
    }
    
    init(frame: CGRect, isRowWithSwitch: Bool, isRowWithTick: Bool = false, title: String = "", value: String = "", isSwitchOn: Bool = false) {
        super.init(frame: frame)
        initialize(isRowWithSwitch, isRowWithTick: isRowWithTick, title: title, value: value, isSwitchOn: isSwitchOn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize(_ isRowWithSwitch: Bool = false, isRowWithTick: Bool = false, title: String = "", value: String = "", isSwitchOn: Bool = false) {
        if let view = Bundle.main.loadNibNamed("PreferencesRow", owner: self, options: nil)![0] as? UIView {
            self.frame = CGRect(origin: self.frame.origin, size: view.frame.size)
            view.isUserInteractionEnabled = true
            self.addSubview(view)
        }
        self.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = false
        
        self.isRowWithTick = isRowWithTick
        self.isSelected = isSwitchOn
        
        self.lblTitle.text = title
        self.lblValue.text = value
        self.txtValue.text = value
        self.switchValue.isOn = isSwitchOn
        
        self.switchValue.isHidden = !isRowWithSwitch
        self.btnNext.isHidden = isRowWithSwitch
        self.lblValue.isHidden = !isRowWithTick
        self.txtValue.isHidden = isRowWithSwitch || isRowWithTick
        
        if (isRowWithTick) {
            self.btnNext.tintColor = UIColor.appBlueColor
            self.btnNext.setImage(UIImage(named: "checkmark"), for: UIControlState())
            setSelected(isSwitchOn)
        }
    }
    
    func setSelected(_ isSelected: Bool) {
        self.isSelected = isSelected
        self.btnNext.setImage(isSelected ? UIImage(named: "checkmark") : nil, for: UIControlState())
    }
    
    @IBAction func onEditDidBegin(_ sender: UITextField) {
        
    }
    
    @IBAction func onEditingChanged(_ sender: UITextField) {
        self.onTextValueIsChanging?(sender)
    }
    
    @IBAction func onEditingDidEnd(_ sender: UITextField) {
        self.onTextValueChanged?(sender)
        sender.resignFirstResponder()
    }
    
    @IBAction func onShouldReturn(_ sender: UITextField) {
        sender.endEditing(true)
    }
    
}

import Foundation
import UIKit

class NotesView: UIView {
    
    @IBOutlet fileprivate weak var lblTitle: UILabel!
    @IBOutlet weak var tvNote: UITextView!
    
    var temporaryText: String?
   
    
    var onFinishEdit: ((_ text:String?) -> ())?
    var onFocus: (() -> ())?
    
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
        if let view = Bundle.main.loadNibNamed("NotesView", owner: self, options: nil)![0] as? UIView {
            self.frame = CGRect(origin: self.frame.origin, size: view.frame.size)
            view.isUserInteractionEnabled = true
            self.addSubview(view)
        }
        
        tvNote.delegate = self
        tvNote.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom:12, right: 12)
        
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
        
        tvNote.delegate = self
        tvNote.inputAccessoryView = toolBar
    }
    
    @objc func doneAction()
    {
        tvNote.resignFirstResponder()
        onFinishEdit?(tvNote.text)
    }
    
    @objc func cancelAction()
    {
        tvNote.resignFirstResponder()
        tvNote.text = temporaryText
    }
    
    @IBAction func didButtonRemovePressed(_ sender: AnyObject) {
    }
    
}

extension NotesView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        temporaryText = tvNote.text
        onFocus?()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        doneAction()
        return true
    }
}

import Foundation
import UIKit

class PreferencesView: UIView {
    
    @IBOutlet fileprivate weak var lblTitle: UILabel!
    @IBOutlet fileprivate weak var containerView: UIView!
    
    @IBOutlet fileprivate weak var footerView: UIView!
    @IBOutlet fileprivate weak var containerConstraintBottom: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var footerLabel: UILabel!
    var rows: [UIView] = []
    var hasDescription = false

    convenience init (rows: [UIView], title: String = "Preferences", description: String = "") {
        self.init(frame: CGRect.zero, rows: rows, title: title, description: description)
    }
    
    init(frame: CGRect, rows: [UIView], title: String, description: String = "") {
        super.init(frame: frame)
        self.rows = rows
        hasDescription = description.count > 0
        initialize()
        lblTitle.text = title
        footerLabel.text = description
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {

        var height: CGFloat = 0
        var yPosition: CGFloat = 0
        rows.forEach {height += $0.frame.height}
        if hasDescription {
            height += 40
        }
        
        if let view = Bundle.main.loadNibNamed("PreferencesView", owner: self, options: nil)![0] as? UIView {
            
            self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: view.frame.width, height: view.frame.height - 160 + height))
            view.frame = self.frame
            view.isUserInteractionEnabled = true
            self.addSubview(view)
        }
        
        if !hasDescription {
            self.footerView.isHidden = true
            self.containerConstraintBottom.constant = 0
        }
        self.containerView.autoresizingMask = .flexibleWidth
        
        var count = 0
        rows.forEach { row in
            let rect = CGRect(x: 0, y: yPosition, width: self.containerView.frame.width, height: row.bounds.height)
            row.autoresizingMask = .flexibleWidth
            row.frame = rect
            row.isUserInteractionEnabled = true
            if count == rows.count - 1 {
                if let rowPreference = row as? PreferencesRow {
                    rowPreference.separatorConstraintLeft.constant = 0
                }
            }
            self.containerView.addSubview(row)
            yPosition += row.bounds.height
            count += 1
        }
    }
}

//
//  ServiceSelectedView.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 12/11/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond

class ServiceSelectedView: UIView {
    
    @IBOutlet fileprivate weak var lblTitle: UILabel!
    @IBOutlet fileprivate weak var lblDescription: UILabel!
    var action: (() -> ())?
    var title: String = ""
    var numberOfItems = Observable<Int>(0)
    
    convenience init (title: String = "Services", action: (() -> ())?) {
        self.init(frame: CGRect.zero, title: title, action: action)
    }
    
    init(frame: CGRect, title: String, action: (() -> ())?) {
        super.init(frame: frame)
        self.title = title
        self.action = action
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        if let view = Bundle.main.loadNibNamed("ServiceSelectedView", owner: self, options: nil)![0] as? UIView {
            
            self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: view.frame.width, height: view.frame.height))
            view.frame = self.frame
            view.isUserInteractionEnabled = true
            self.addSubview(view)
        }
        self.lblTitle.text = title
        numberOfItems.map{ number in
            if number == 0 {
                return ""
            } else {
                return "\(number) Selected"
            }
        }.bind(to: lblDescription.bnd_text)
    }
    
    @IBAction func onAction(_ sender: AnyObject) {
        action?()
    }
}


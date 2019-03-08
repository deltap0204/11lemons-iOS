//
//  ServiceDefaultBackgroundWithText.swift
//  lemonapp
//
//  Created by Mauro Taroco on 7/11/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import UIKit

class ServiceDefaultBackgroundWithText: UIView {

    @IBOutlet var noIconImg: UIImageView!
    @IBOutlet var serviceNameLbl: UILabel!
    var serviceName: String = ""
    
    convenience init (serviceName: String) {
        self.init(frame: CGRect.zero, serviceName: serviceName)
    }
    
    init(frame: CGRect, serviceName: String) {
        self.serviceName = serviceName
        super.init(frame: CGRect(x: 0, y: 0, width: 62, height: 62))
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        
        if let view = Bundle.main.loadNibNamed("ServiceDefaultBackgroundWithText", owner: self, options: nil)![0] as? UIView {
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.translatesAutoresizingMaskIntoConstraints = true
            view.frame = self.bounds
            self.addSubview(view)
        }
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.backgroundColor = UIColor.clear
        self.serviceNameLbl.textColor = UIColor.appBlueColor
        self.serviceNameLbl.text = serviceName
    }

}

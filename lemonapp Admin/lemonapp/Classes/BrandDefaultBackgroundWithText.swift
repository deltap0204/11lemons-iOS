//
//  BrandDefaultBackgroundWithText.swift
//  lemonapp
//
//  Created by Mauro Taroco on 7/16/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation
import UIKit

class BrandDefaultBackgroundWithText: UIView {
    
    @IBOutlet var brandNameLbl: UILabel!
    var brandName: String = ""
    
    convenience init (brandName: String) {
        self.init(frame: CGRect.zero, brandName: brandName)
    }
    
    init(frame: CGRect, brandName: String) {
        self.brandName = brandName
        super.init(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        
        if let view = Bundle.main.loadNibNamed("BrandDefaultBackgroundWithText", owner: self, options: nil)![0] as? UIView {
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.translatesAutoresizingMaskIntoConstraints = true
            view.frame = self.bounds
            self.addSubview(view)
        }
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.backgroundColor = UIColor.clear
        //self.serviceNameLbl.textColor = UIColor.appBlueColor
        self.brandNameLbl.text = brandName
    }
    
}


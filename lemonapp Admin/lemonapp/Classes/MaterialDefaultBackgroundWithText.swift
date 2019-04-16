//
//  MaterialDefaultBackgroundWithText.swift
//  lemonapp
//
//  Created by Mauro Taroco on 7/17/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation
import UIKit

class MaterialDefaultBackgroundWithText: UIView {
    
    @IBOutlet var materialNameLbl: UILabel!
    var materialName: String = ""
    
    convenience init (materialName: String) {
        self.init(frame: CGRect.zero, materialName: materialName)
    }
    
    init(frame: CGRect, materialName: String) {
        self.materialName = materialName
        super.init(frame: CGRect(x: 0, y: 0, width: 62, height: 62))
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        
        if let view = Bundle.main.loadNibNamed("MaterialDefaultBackgroundWithText", owner: self, options: nil)![0] as? UIView {
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.translatesAutoresizingMaskIntoConstraints = true
            view.frame = self.bounds
            self.addSubview(view)
        }
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.backgroundColor = UIColor.clear
        self.materialNameLbl.textColor = UIColor.appBlueColor
        self.materialNameLbl.text = materialName
    }
    
}

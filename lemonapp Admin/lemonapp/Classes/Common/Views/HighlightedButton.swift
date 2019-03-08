//
//  HighlightedButton.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond

class HighlightedButton: UIButton {
    
    fileprivate var _backgroundColor: UIColor?
    fileprivate var highlitedBackgroundColor: UIColor?
    var btnHighlighted = Observable<Bool>(false)
    var btnSelected = Observable<Bool>(false)
    var btnEnabled = Observable<Bool>(true)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //btnHighlighted.bind(to: self.bnd_highlighted)
        //btnSelected.bind(to: self.bnd_selected)
        //btnEnabled.bind(to: self.bnd_enabled)
        btnHighlighted.observeNext { [weak self] in
            self?.backgroundColor = $0 ? self?.highlitedBackgroundColor : self?._backgroundColor
        }
    }
    
    override var backgroundColor: UIColor? {
        set {
            if (_backgroundColor == nil) {
                _backgroundColor = newValue
                updateHighlitedBackgroundColor()
            }
            super.backgroundColor = newValue
        }
        get {
            return super.backgroundColor
        }
    }
    
    override var isHighlighted: Bool {
        set {
            super.isHighlighted = newValue
            //btnHighlighted.value = newValue
            //self.bnd_highlighted.value = newValue
            self.btnHighlighted.value = newValue
            //self.btnHighlighted.next(newValue)
        }
        get {
            return super.isHighlighted
        }
    }
    
    
    override var isSelected: Bool {
        set {
            super.isSelected = newValue
            //self.bnd_selected.value = newValue
            btnSelected.value = newValue
        }
        get {
            return super.isSelected
        }
    }
    
    override var isEnabled: Bool {
        set {
            super.isEnabled = newValue
            //self.bnd_enabled.value = newValue
            btnEnabled.value = newValue
            alpha = newValue ? 1.0 : 0.8
        }
        get {
            return super.isEnabled
        }
    }
    
    fileprivate func updateHighlitedBackgroundColor() {
        if let backgroundColor = _backgroundColor {
            var red, green, blue, alpha: CGFloat
            red = 0
            green = 0
            blue = 0
            alpha = 0

            backgroundColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            highlitedBackgroundColor = UIColor(red: red+15/255, green: green+15/255, blue: blue+15/255, alpha: alpha+40/255)
        } else {
            highlitedBackgroundColor = nil
        }
    }
}

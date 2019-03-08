//
//  GarmentCardEmptyView.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 12/1/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation

final class GarmentCardEmptyView: UIView {
    
    fileprivate let height: CGFloat = CGFloat(66)
    var currentView: UIView?
    
    var heightChanged: ((_ height:CGFloat) -> ())?
    var withRadius: Bool
    var isLoading: Bool
    
    convenience init(withRadius:Bool = false, isLoading: Bool = false) {
        self.init(frame: CGRect.zero, withRadius: withRadius, isLoading: isLoading)
    }
    
    init(frame: CGRect, withRadius:Bool,isLoading: Bool) {
        self.withRadius = withRadius
        self.isLoading = isLoading
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.withRadius = false
        self.isLoading = false
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        
        if let view = Bundle.main.loadNibNamed("GarmentCardEmptyView", owner: self, options: nil)![0] as? UIView {
            self.frame = CGRect(origin: self.frame.origin, size: view.frame.size)
            view.frame = self.frame
            self.currentView = view
            self.addSubview(self.currentView!)
            self.currentView?.alpha = isLoading ? 1.0 : 0.5
            let constraintWidth = NSLayoutConstraint(item: currentView!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0)
            let constraintHeight = NSLayoutConstraint(item: currentView!, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0)
            
            let xConstraint = NSLayoutConstraint(item: currentView!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
            let yConstraint = NSLayoutConstraint(item: currentView!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
            NSLayoutConstraint.activate([constraintWidth, constraintHeight, xConstraint, yConstraint])            
        }
    }
    
    @IBInspectable var cRadius: CGFloat = 8
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.5
    
    override func layoutSubviews() {
        if withRadius {
            applyCornerRadius(self)
            if let currentView = self.currentView {
                applyCornerRadius(currentView)
            }
        }
    }
    
    fileprivate func applyCornerRadius(_ view: UIView) {
        view.layer.cornerRadius = cRadius
//        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cRadius)
        
        view.layer.masksToBounds = false
//        view.layer.shadowColor = shadowColor?.CGColor
//        view.layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
//        view.layer.shadowOpacity = shadowOpacity
//        view.layer.shadowPath = shadowPath.CGPath
    }
}

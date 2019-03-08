//
//  PreferenceUserRowView.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 2/24/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond

class PreferenceUserRowView: UIView {
    
    @IBOutlet fileprivate weak var lblValue: UILabel!
    @IBOutlet fileprivate weak var lblNameValue: UILabel!
    fileprivate var currentView: UIView?
    let viewModel: PreferenceRowUser?

    convenience init(viewModel: PreferenceRowUser) {
        self.init(frame: CGRect.zero, viewModel: viewModel)
    }
    
    init(frame: CGRect, viewModel: PreferenceRowUser) {
        self.viewModel = viewModel
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = nil
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        if let view = Bundle.main.loadNibNamed("PreferenceUserRowView", owner: self, options: nil)![0] as? UIView {
             self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: view.frame.width, height: viewModel?.getHeight() ?? CGFloat(0)))
            view.isUserInteractionEnabled = true
            self.currentView = view
            self.addSubview(currentView!)
            let constraintWidth = NSLayoutConstraint(item: currentView!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0)
            let constraintHeight = NSLayoutConstraint(item: currentView!, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0)
            
            let xConstraint = NSLayoutConstraint(item: currentView!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
            let yConstraint = NSLayoutConstraint(item: currentView!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
            NSLayoutConstraint.activate([constraintWidth, constraintHeight, xConstraint, yConstraint])
        }
        
        lblNameValue.text = viewModel?.getPreferenceName() ?? ""
        viewModel?.bindTextLabelValue(lblValue)
        addTouchEvents()
    }
    
    fileprivate func addTouchEvents()
    {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PreferenceUserRowView.customAction(_:)));
        self.addGestureRecognizer(gestureRecognizer);
    }
    
    @objc func customAction(_ sender: UITapGestureRecognizer) {
        viewModel?.showModal()
    }
}


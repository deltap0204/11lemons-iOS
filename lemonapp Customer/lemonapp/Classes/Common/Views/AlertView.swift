//
//  AlertView.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit

final class AlertView: UIView {
    
    static let ANIMATION_DURATION: TimeInterval = 0.2
    
    typealias Completion = () -> Void
    
    @IBOutlet fileprivate weak var containerView: UIView!
    @IBOutlet fileprivate weak var labelContainer: UIView!
    
    fileprivate var completion: Completion?
    
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
        
        if let view = Bundle.main.loadNibNamed("AlertView", owner: self, options: nil)![0] as? UIView {
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.frame = self.bounds
            containerView.alpha = 0
            containerView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5);
            labelContainer.layer.shadowColor = UIColor.black.cgColor
            labelContainer.layer.shadowOffset = CGSize(width: 0, height: 45)
            labelContainer.layer.shadowRadius = 20
            labelContainer.layer.shadowOpacity = 0.9
            labelContainer.layer.masksToBounds = false
            self.addSubview(view)
        }
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.backgroundColor = UIColor.clear

        let gr = UITapGestureRecognizer(target: self, action: #selector(AlertView.dismiss))
        self.addGestureRecognizer(gr)
    }
    
    func showInView(_ parent: UIView?) {
        if let parent = parent {
            self.frame = parent.bounds
            parent.addSubview(self)
            UIView.animate(withDuration: AlertView.ANIMATION_DURATION, delay:0, options:UIViewAnimationOptions.curveEaseOut, animations: { [weak self] in
                self?.containerView.transform = CGAffineTransform.identity;
                self?.containerView.alpha = 1
                }, completion: nil)
            
            let delayTime = DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
                self?.dismiss()
            }
        }
    }
    
    func showInView(_ parent: UIView?, completion: Completion?) {
        self.completion = completion
        showInView(parent)
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: AlertView.ANIMATION_DURATION, delay:0, options:UIViewAnimationOptions.curveEaseOut, animations: { [weak self] in
                self?.alpha = 0
            }) { [weak self] _ in
                self?.removeFromSuperview()
                self?.completion?()
        }
    }
}

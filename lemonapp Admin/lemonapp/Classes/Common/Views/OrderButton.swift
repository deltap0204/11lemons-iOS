//
//  OrderButton.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

enum OrderButtonMode {
    case quick, defaultButton
}

@IBDesignable
final class OrderButton: UIView {
    
    @IBOutlet fileprivate weak var orderButton: UIButton!
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    
    let bnd_mode: Observable<OrderButtonMode> = Observable(OrderButtonMode.defaultButton)
    
    var bnd_tap: SafeSignal<Void> {
        return orderButton.bnd_tap
    }
    
    /*
 var bnd_tap: SafeSignal<Void> {
 return orderButton.reactive.tap
 }
 */
    
    //var bnd_slide: Observable<Bool> = Observable(false)
    var bnd_slide = SafeReplaySubject<Void>()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if let view = Bundle.main.loadNibNamed("OrderButton", owner: self, options: nil)![0] as? UIView {
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.frame = self.bounds
            self.addSubview(view)
        }
        
        bnd_mode.map { $0 == OrderButtonMode.defaultButton }.bind(to: bnd_userInteractionEnabled)
        
        //TODO migration-check
        //Check this warning
        bnd_mode.filter { $0 == OrderButtonMode.defaultButton }.observeNext { [weak self, scrollView] _ in
            if let contentWidth = scrollView?.contentSize.width {
                scrollView?.setContentOffset(CGPoint(x: contentWidth / 2, y: 0), animated: true)
            }
            self?.activityIndicator.isHidden = true
        }
        
        activityIndicator.isHidden = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.layoutSubviews()
        scrollView.contentOffset = CGPoint(x: self.frame.width, y: 0)
    }
}


extension OrderButton: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 {
            bnd_slide.next(())
            isUserInteractionEnabled = false
            activityIndicator.isHidden = false
        }
    }
}

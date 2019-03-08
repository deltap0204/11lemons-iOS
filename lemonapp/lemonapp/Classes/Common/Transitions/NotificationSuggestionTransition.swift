//
//  TutorialOverlayTransition.swift
//  lemonapp
//
//  Created by Svetlana Dedunovich on 5/4/16.
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


final class TutorialOverlayTransition: NSObject, UIViewControllerAnimatedTransitioning {
   
    fileprivate var reverse: Bool = false
    fileprivate var blurView: UIView?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        
        if !reverse {
            let blur = UIBlurEffect(style: UIBlurEffectStyle.dark)
            blurView = UIVisualEffectView(effect: blur)
            blurView?.alpha = 1
        }
        
        if toView != nil {
            toView?.frame = CGRect(origin: CGPoint.zero, size: container.frame.size)
            container.addSubview(toView!)
        }
        if fromView != nil {
            container.addSubview(fromView!)
        }
        
        let duration = self.transitionDuration(using: transitionContext)
        
        toView?.alpha = reverse ? 1.0 : 0.0
        blurView?.alpha = reverse ? 1.0 : 0.0
        
        if !reverse {
            blurView!.frame = CGRect(origin: CGPoint.zero, size: container.frame.size)
            container.addSubview(blurView!)
            container.sendSubview(toBack: blurView!)
        }
        
        UIView.animate(withDuration: duration, animations: { 
            if self.reverse {
                fromView?.alpha = 0.0
            } else {
                toView?.alpha = 1.0
            }
            
            self.blurView?.alpha = self.reverse ? 0.0 : 1.0
        }, completion: { _ in
            if self.reverse {
                self.blurView?.removeFromSuperview()
            }
            transitionContext.completeTransition(true)
        })

    }

}


extension TutorialOverlayTransition: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        reverse = false
        return self
    }
    
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        reverse = true
        return self
    }
}

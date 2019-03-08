//
//  YellowNavigationController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond

enum NavigationBarStyle {
    case yellow, black, transparent, blue
    
    var color: UIColor {
        switch self {
        case .yellow:
            return UIColor.lemonColor()
        case .black:
            return UIColor.lemonBlackColor()
        case .blue:
            return UIColor.lemonBlueColor()
        default:
            return UIColor.clear
        }
    }
}


protocol YellowNavigationControllerChild {
    func preferredBarStyle() -> NavigationBarStyle
}


final class YellowNavigationController: UINavigationController {
    
    var barStyle: Observable<NavigationBarStyle> = Observable(.yellow)
    var hideStatusBar = Observable(false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLemonBackground()
        
        if #available(iOS 8.2, *) {
            navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor.white]
        } else {
            navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: UIColor.white]
        }
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        
        navigationBar.backIndicatorImage = UIImage(assetIdentifier: .WhiteBackArrow).resizableImage(withCapInsets: UIEdgeInsets(top: 12, left: 20, bottom: 0, right: 0))
        
        barStyle.observeNext { [weak navigationBar] style in
            navigationBar?.backgroundColor = style.color
            navigationBar?.barTintColor = style.color
            navigationBar?.tintColor = UIColor.white
            switch style {
            case .transparent:
                navigationBar?.isTranslucent = true
                navigationBar?.setBackgroundImage(UIImage(), for: .default)
                break
            default:
                navigationBar?.isTranslucent = false
                break
            }
        }
        
        hideStatusBar.observeNext { [weak self] _ in
            self?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return hideStatusBar.value
    }
    
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        setNeedsStatusBarAppearanceUpdate()
        return super.popToRootViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        setNeedsStatusBarAppearanceUpdate()
        return super.popToViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        setNeedsStatusBarAppearanceUpdate()
        let total = viewControllers.count
        if total > 1 {
            if let controller = viewControllers[total - 2] as? YellowNavigationControllerChild {
                barStyle.next(controller.preferredBarStyle())
            }
        }
        let popedVC = super.popViewController(animated: animated)
        popedVC?.onExit()
        return popedVC
    }
    
}

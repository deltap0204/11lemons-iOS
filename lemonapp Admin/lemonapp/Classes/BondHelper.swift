//
//  BondHelper.swift
//  lemonapp
//
//  Created by Mauro Taroco on 5/15/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit

//To check types of each var: https://github.com/DeclarativeHub/Bond/tree/master/Sources/Bond/UIKit

extension UIButton {
    
    public var bnd_title: Bond<String?> {
        return self.reactive.title
    }
    
    public var bnd_tap: SafeSignal<Void> {
        return self.reactive.tap
    }
    
    public var bnd_highlighted: Bond<Bool> {
        return self.reactive.isHighlighted
    }
    
    public var bnd_selected: Bond<Bool> {
        return self.reactive.isSelected
    }
    
    public var bnd_backgroundImage: Bond<UIImage> {
        return self.reactive.backgroundImage
    }
    
    public var bnd_image: Bond<UIImage> {
        return self.reactive.image
    }
    
    public var bnd_enabled: Bond<Bool> {
        return self.reactive.isEnabled
    }
    /*
    public var bnd_backgroundColor: Bond<UIColor?> {
        return self.reactive.backgroundColor
    }
     */
}

extension UILabel {
    
    public var bnd_text: Bond<String?> {
        return self.reactive.text
    }
    
    public var bnd_attributedText: Bond<NSAttributedString?> {
        return self.reactive.attributedText
    }
    
    public var bnd_textColor: Bond<UIColor?> {
        return self.reactive.textColor
    }
}

extension UITextField {
    
    public var bnd_text: DynamicSubject<String?> {
        return self.reactive.text
    }
    
    public var bnd_enabled: Bond<Bool> {
        return self.reactive.isEnabled
    }
    
    public var bnd_textColor: Bond<UIColor?> {
        return self.reactive.textColor
    }
}

extension UITextView {
    public var bnd_text: DynamicSubject<String?> {
        return self.reactive.text
    }
    
    public var bnd_textColor: Bond<UIColor?> {
        return self.reactive.textColor
    }
}

extension UIImageView {
    public var bnd_image: Bond<UIImage?> {
        return self.reactive.image
    }
}

extension UIView {
    
    public var bnd_userInteractionEnabled: Bond<Bool> {
        return self.reactive.isUserInteractionEnabled
    }
    
    public var bnd_hidden: Bond<Bool> {
        return self.reactive.isHidden
    }
    
    public var bnd_backgroundColor: Bond<UIColor?> {
        return self.reactive.backgroundColor
    }
    
    public var bnd_alpha: Bond<CGFloat> {
        return self.reactive.alpha
    }
    
    public var bnd_tintColor: Bond<UIColor?> {
        return self.reactive.tintColor
    }
    
}

extension UIScrollView {
    public var bnd_slide: SafeSignal<Void> {
        return self.reactive.base.bnd_slide
    }
}

extension UISwitch {
    public var bnd_on: DynamicSubject<Bool> {
        return self.reactive.isOn
    }
}

extension UIBarButtonItem {
    public var bnd_image: Bond<UIImage?> {
        return self.reactive.image
    }
    
    public var bnd_title: Bond<String?> {
        return self.reactive.title
    }
}

extension UIActivityIndicatorView {
    public var bnd_animating: Bond<Bool> {
        return self.reactive.isAnimating
    }
}

extension UISlider {
    public var bnd_enabled: Bond<Bool> {
        return self.reactive.isEnabled
    }
    
    public var bnd_value: DynamicSubject<Float> {
        return self.reactive.value
    }
}

extension UIControl {
    public func bnd_controlEvent(_ events: UIControlEvents) -> SafeSignal<Void> {
        return self.reactive.controlEvents(events)
    }
}

extension NotificationCenter {
    
    /// Observe notifications using a signal.
    public func bnd_notification(_ name: NSNotification.Name, object: AnyObject? = nil) -> Signal<Notification, NoError> {
        return self.reactive.notification(name:name, object:object)
    }
}

extension MutableObservableArray {
    //TODO: check if this method is correct
    public func removeSubrange(_ indexes: [Int]) {
        for index in indexes.sorted(by: >) {
            remove(at: index)
        }
    }
}

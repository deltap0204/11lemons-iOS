//
//  PrivacyPolicyViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit


final class PrivacyPolicyViewController: UIViewController {
    
    @IBOutlet fileprivate weak var textView: UITextView!
    @IBOutlet fileprivate weak var backButton: UIButton!
    
    @IBOutlet var backBtnHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: backBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: backButton)
        setLemonBackground()
        let path = Bundle.main.path(forResource: "PP", ofType: "txt")!
        if let terms = try? NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) {
            textView.text = terms as String
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.fixBackArrow()
    }
}

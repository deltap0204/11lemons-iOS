//
//  ReferralProgramViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import UIKit

final class ReferralProgramViewController: UIViewController {
    
    @IBOutlet var codeLabel: UILabel!
    @IBOutlet var hintLabel: UILabel!
    @IBOutlet fileprivate weak var walletView: WalletView!
    
    @IBOutlet var doneBtn: LeftRightImageButton!
    @IBOutlet var doneBtnHeight: NSLayoutConstraint!
    
    fileprivate let viewModel = ReferralViewModel()
    
    fileprivate static let HintAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.white]
    fileprivate static let HighlightHintAttribute = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.appBlueColor]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: doneBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: doneBtn)
        bindViewModel(viewModel)
    }
    
    
    func bindViewModel(_ viewModel: ReferralViewModel) {

        viewModel.code.bind(to: codeLabel.bnd_text)

        viewModel.code.map { code in
            let codeToUse = code ?? ""
            
            let hint = NSMutableAttributedString(string: "", attributes: nil)
            
            let part1 = NSAttributedString(string: ReferralViewModel.HintPart1, attributes: ReferralProgramViewController.HintAttributes)
            hint.append(part1)
            
            let codePart = NSAttributedString(string: codeToUse, attributes: ReferralProgramViewController.HighlightHintAttribute)
            hint.append(codePart)
            
            let part2 = NSAttributedString(string: ReferralViewModel.HintPart2, attributes: ReferralProgramViewController.HintAttributes)
            hint.append(part2)

            return hint
        }.bind(to: hintLabel.bnd_attributedText)
        
        viewModel.walletViewModel.observeNext { [weak self] in self?.walletView.viewModel = $0 }
    }
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBAction func share(_ sender: UIButton) {
        let textToShare = "Use \(viewModel.code.value ?? "") at signup and you'll get $10 off your first order with @11lemons!\n\(ReferralViewModel.AppStoreLink)"
        let objectsToShare = [textToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
    
        activityVC.popoverPresentationController?.sourceView = sender
        present(activityVC, animated: true, completion: nil)
    }
}


extension ReferralProgramViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

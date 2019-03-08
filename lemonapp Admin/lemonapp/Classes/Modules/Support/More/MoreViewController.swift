//
//  MoreViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Bond


final class MoreViewController: UIViewController {

    @IBOutlet fileprivate weak var textView: UITextView!
    @IBOutlet fileprivate weak var placeholder: UILabel!
    @IBOutlet fileprivate weak var submitButton: UIButton!
    
    @IBOutlet var submitBtnHeight: NSLayoutConstraint!
    
    fileprivate let viewModel = MoreViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: submitBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: submitButton)
        bindViewModel(viewModel)
        textView.delegate = self
    }
    
    func bindViewModel(_ viewModel: MoreViewModel) {
        
        viewModel.shouldHideNotesHint.observeOn(.main).bind(to: placeholder.bnd_hidden)
        viewModel.shouldHideNotesHint.map { [weak self] hide in
            if hide {
                return hide
            } else {
                let isTextViewInEditMode = self!.textView.isFirstResponder
                if isTextViewInEditMode {
                    return true
                }
                return false
            }
        }.bind(to: placeholder.bnd_hidden)

        viewModel.notes.bidirectionalBind(to: textView.bnd_text)
        
        submitButton.bnd_tap.observeNext {
            showLoadingOverlay()
            viewModel.saveChanges.execute { [weak self] resolver in
                do {
                    try resolver()
                    AlertView().showInView(self?.navigationController?.parent?.view)
                } catch let error as BackendError {
                    self?.handleError(error)
                } catch let error {
                    print(error)
                }
                hideLoadingOverlay()
                self?.onBack(self?.submitButton)
            }
        }
    }
}

extension MoreViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.rangeOfCharacter(from: CharacterSet.newlines) == nil {
            return true
        }
        textView.resignFirstResponder()
        return false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholder.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholder.isHidden = textView.text.count > 0
    }
}

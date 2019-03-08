//
//  FeedbackView.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 9/28/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import UIKit
import Bond

class FeedbackView: UIView {
    
    fileprivate let heightAdmin = CGFloat(100)
    
    @IBOutlet fileprivate weak var lblTitle: UILabel!
    @IBOutlet var starButtons: [UIButton]!
    @IBOutlet fileprivate weak var btnLeaveFeedback: UIButton!
    @IBOutlet fileprivate weak var txtView: UITextView!
    @IBOutlet fileprivate weak var buttonsView: UIView!
    @IBOutlet fileprivate weak var viewIssue: UIView!
    
    
    fileprivate var currentView: UIView?
    var heightChanged: ((_ height:CGFloat) -> ())?

    var viewModel: FeedbackViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    convenience init() {
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
        
        if let view = Bundle.main.loadNibNamed("FeedbackView", owner: self, options: nil)![0] as? UIView {
            self.frame = CGRect(origin: self.frame.origin, size: view.frame.size)
            view.isUserInteractionEnabled = true
            let height = heightAdmin
            self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: UIScreen.main.bounds.width, height: height))
            view.frame = self.frame
            view.isUserInteractionEnabled = true
            self.currentView = view
            self.addSubview(self.currentView!)
            self.btnLeaveFeedback.layer.masksToBounds = true
            self.btnLeaveFeedback.layer.cornerRadius = CGFloat(5)
        }
        self.txtView.delegate = self
    }
    
    fileprivate func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        viewModel.titleText.bind(to: lblTitle.bnd_text)
        viewIssue.isHidden = true
        btnLeaveFeedback.isHidden = true
        viewModel.feedbackText.bidirectionalBind(to: self.txtView.bnd_text)

        loadStartFilled(viewModel.feedbackRate)
    }

    func updateHeight(_ height: CGFloat) {
    }
    
    @IBAction func onLeaveFeedback(_ sender: AnyObject) {
        guard let viewModel = self.viewModel else { return }
        viewModel.isFeedbackMode.value = !viewModel.isFeedbackMode.value
    }
    
    @IBAction func onSubmit(_ sender: AnyObject) {
        guard let viewModel = self.viewModel else { return }
        viewModel.onSubmit()
    }
    
    @IBAction func onCancel(_ sender: AnyObject) {
        guard let viewModel = self.viewModel else { return }
        viewModel.resetFeedbackText()
        viewModel.isFeedbackMode.value = false
    }
    
    @IBAction func onIssue(_ sender: AnyObject) {
        guard let viewModel = self.viewModel else { return }
        viewModel.reportIssue()
    }
    
    @IBAction func onStarAction(_ sender: UIButton) {
    }
    
    fileprivate func loadStartFilled(_ rate: Int) {
        starButtons.forEach {
            let imageName = $0.tag <= rate ? "FilledStar" : "EmptyStar"
            $0.setImage(UIImage(named: imageName), for: UIControlState())
        }
    }
}

extension FeedbackView: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard let viewModel = self.viewModel else { return true }
        
        if textView.text == viewModel.feedbackPlaceholder {
            viewModel.feedbackText.value = ""
        }
        return true
    }
}

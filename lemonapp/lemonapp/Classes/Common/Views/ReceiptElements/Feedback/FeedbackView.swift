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
    fileprivate let heightCompact = CGFloat(400) // 204)
    fileprivate let height = CGFloat(382)
    
    @IBOutlet fileprivate weak var lblTitle: UILabel!
    @IBOutlet var starButtons: [UIButton]!
    @IBOutlet fileprivate weak var btnLeaveFeedback: UIButton!
    @IBOutlet fileprivate weak var txtView: UITextView!
    @IBOutlet fileprivate weak var buttonsView: UIView!
    @IBOutlet fileprivate weak var viewIssue: UIView!
    
    
    fileprivate var currentView: UIView?
    let isAdmin: Bool
    var heightChanged: ((_ height:CGFloat) -> ())?

    var viewModel: FeedbackViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    convenience init(isAdmin: Bool) {
        self.init(frame: CGRect.zero, isAdmin: isAdmin)
    }
    
    init(frame: CGRect, isAdmin: Bool) {
        self.isAdmin = isAdmin
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.isAdmin =  false
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        
        if let view = Bundle.main.loadNibNamed("FeedbackView", owner: self, options: nil)![0] as? UIView {
            self.frame = CGRect(origin: self.frame.origin, size: view.frame.size)
            view.isUserInteractionEnabled = true
            let height = self.isAdmin ? heightAdmin : heightCompact
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
        viewModel.isAdmin.bind(to: viewIssue.bnd_hidden)
        viewModel.isAdmin.bind(to: btnLeaveFeedback.bnd_hidden)
        viewModel.feedbackText.bidirectionalBind(to: self.txtView.bnd_text)
        
        
        
        loadStartFilled(viewModel.feedbackRate)
        viewModel.isFeedbackMode.observeNext { [weak self] isFeedback in
            guard let strongSelf = self else { return }
            guard !strongSelf.isAdmin else { return }
            
            if isFeedback {
                strongSelf.heightChanged?(strongSelf.height)
                strongSelf.buttonsView.isHidden = false
                strongSelf.txtView.isHidden = false
                strongSelf.btnLeaveFeedback.setTitleColor(UIColor.appBlueColor, for: UIControlState())
                strongSelf.btnLeaveFeedback.backgroundColor = UIColor.clear
            } else {
                strongSelf.heightChanged?(strongSelf.heightCompact)
                strongSelf.buttonsView.isHidden = true
                strongSelf.txtView.isHidden = true
                strongSelf.btnLeaveFeedback.setTitleColor(UIColor.white, for: UIControlState())
                strongSelf.btnLeaveFeedback.backgroundColor = UIColor.appBlueColor
            }
        }
    }

    func updateHeight(_ height: CGFloat) {
//        self.frame = CGRect(origin: self.frame.origin, size: CGSizeMake(UIScreen.mainScreen().bounds.width, height))
//        currentView!.frame = self.frame
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
        guard let viewModel = self.viewModel, !self.isAdmin else { return }
        viewModel.feedbackRate = sender.tag
        loadStartFilled(sender.tag)
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

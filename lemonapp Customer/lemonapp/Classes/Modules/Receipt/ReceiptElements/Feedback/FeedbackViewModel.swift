//
//  FeedbackViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 11/13/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond

final class FeedbackViewModel {
    
    let feedbackPlaceholder = "Anything we can do better? \nAnything we should keep doing?"
    let userTitle = "How was your experience?"
    
    let isFeedbackMode = Observable<Bool>(false)
    let feedbackText = Observable<String?>("")
    let titleText = Observable<String?>("")
    var feedbackRate = 0
    
    init(text: String = "", rate: Int = 0) {
        self.feedbackRate = rate
        self.feedbackText.value = text.isEmpty ? feedbackPlaceholder : text
        self.titleText.value = userTitle
    }
    
    func resetFeedbackText() {
        feedbackText.value = feedbackPlaceholder
    }
    
    func reportIssue() {
        //TODO: report issue
    }
    
    func onSubmit() {
        //TODO: send feedback report
    }
}

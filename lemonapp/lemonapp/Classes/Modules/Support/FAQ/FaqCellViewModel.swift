//
//  FaqCellViewModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


final class FaqCellViewModel {
    
    let question: String
    let answer: String
    var shouldShowAnswer = false
    
    init(faqItem: FaqItem) {
        question = faqItem.question
        answer = faqItem.answer
    }
}
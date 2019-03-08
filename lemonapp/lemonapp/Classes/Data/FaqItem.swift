//
//  FaqItem.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class FaqItem {
    
    var question: String
    var answer: String
    fileprivate var _dataModel: FAQItemModel
    
    init(question: String, answer: String, dataModel: FAQItemModel? = nil) {
        self.question = question
        self.answer = answer
        self._dataModel = dataModel ?? FAQItemModel(question: question, answer: answer)
    }
    
    convenience init(faqItemModel: FAQItemModel) {
        self.init(question: faqItemModel.question,
            answer: faqItemModel.answer,
            dataModel: faqItemModel)
    }
}

extension FaqItem: DataModelWrapper {
    
    var dataModel: NSManagedObject {
        return _dataModel
    }
    
    func syncDataModel() {
        _dataModel.question = self.question
        _dataModel.answer = self.answer
        saveDataModelChanges()
    }
}


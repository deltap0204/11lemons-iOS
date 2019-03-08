//
//  FAQItemModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class FAQItemModel: NSManagedObject {
    
    @NSManaged var question: String
    @NSManaged var answer: String
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init (context: NSManagedObjectContext = LemonCoreDataManager.context, question: String, answer: String) {
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).modelName, in: context)!
        self.init(entity: entity, insertInto: nil)
        self.question = question
        self.answer = answer
    }
}

extension FAQItemModel: ModelNameProvider {
    class var modelName: String { return "FAQItem" }
}

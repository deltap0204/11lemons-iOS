//
//  FaqViewModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond


final class FaqViewModel {

    let faqViewModels = MutableObservableArray<FaqCellViewModel>([])
    
    init() {
        DataProvider.sharedInstance.faqs.observeNext { [weak self] in
            self?.faqViewModels.replace(with: $0.map{ FaqCellViewModel(faqItem: $0) })
        }
    }
    
    func update(_ completion: @escaping () -> Void) {
        DataProvider.sharedInstance.refreshFaqs {
            completion()
        }
    }
    
    func toggleFaqAtIndexPath(_ indexPath: IndexPath) {
        let faqViewModel = faqViewModels.array[indexPath.row]
        faqViewModel.shouldShowAnswer = !faqViewModel.shouldShowAnswer
    }
}

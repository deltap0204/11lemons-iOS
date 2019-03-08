//
//  MoreViewModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit


final class MoreViewModel {
    
    var notes = Observable<String?>("")
    
    fileprivate(set) lazy var shouldHideNotesHint: SafeSignal<Bool> = {
        return self.notes.map { !($0?.isEmpty ?? true) }
    }()
    
    
    var saveChanges: Action<() throws -> Void> {
        return Action { [weak self] in
            Signal { [weak self] sink in
                _ = LemonAPI.addComment(text: self?.notes.value ?? "").request().observeNext { (resolver: EventResolver<Void>) in
                    
                    do {
                        try resolver()
                        //sink.completed(with:  return }
                        sink.completed(with: {return})
                    } catch let error {
                        //sink.completed(with:  throw error }
                        sink.completed(with: {throw error})
                    }
 /*
                    switch event {
                    case .completed:
                        observer.completed()
                    case .failed(let error):
                        //observer.failed(error as NSError)
                        observer.completed(with: {throw error})
                    case .next(let element):
                        observer.completed(with: {element()})
                    }
 */
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
}

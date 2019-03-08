//
//  Action.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Bond
import ReactiveKit

final class Action<T> {
    var executing = Observable(false)
    fileprivate var task: (() -> Signal<T,NSError>)?
    
    func execute(_ observer: @escaping (T)->()) {
        guard let task = task else { return }
        executing.value = true
        task().observeNext { [weak self] result  in
            self?.executing.value = false
            observer(result)
        }
    }
    
    init(task: @escaping () -> Signal<T,NSError>) {
        self.task = task
    }
}

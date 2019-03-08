//
//  AddNoteFlow.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit


final class AddNoteFlow {
    
    typealias Completion = () -> Void
    
    fileprivate let viewController: UIViewController
    fileprivate let completion: Completion
    fileprivate let order: Order
    
    init(withOrder order: Order, fromViewController viewController: UIViewController, completion: @escaping Completion) {
        self.viewController = viewController
        self.completion = completion
        self.order = order
        start()
    }
    
    fileprivate func start() {
        showConfirmationAlert()
    }
    
    fileprivate func showConfirmationAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        for noteType in NoteType.allValues {
            alert.addAction(UIAlertAction(title: noteType.alertTitle, style: .default, handler: { _ in
                self.showNoteInputAlert(noteType)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func showNoteInputAlert(_ type: NoteType) {
        let alert = UIAlertController(title: type.alertTitle, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { textField in
            textField.placeholder = "Please, Enter Note Here"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default) { _ in
            alert.dismiss(animated: true, completion: nil)
            if let noteString = alert.textFields?.first?.text {
                let note = Note(type: type, order: self.order, text: noteString)
                _ = LemonAPI.addNote(note: note).request().observeNext { (_: EventResolver<String>) in }
            }
        })
        
        
        viewController.present(alert, animated: true, completion: nil)
    }
}

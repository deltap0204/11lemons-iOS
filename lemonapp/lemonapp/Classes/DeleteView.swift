//
//  DeleteView.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 11/7/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import UIKit

class DeleteView: UIView {
    
    @IBOutlet fileprivate weak var btnDelete: UIButton!
    
    var deleteAction: (() -> ())?
    var deleteBtnTitle: String = ""
    
    convenience init (deleteBtnTitle: String = "Delete", deleteAction: (() -> ())?) {
        self.init(frame: CGRect.zero, deleteBtnTitle: deleteBtnTitle, deleteAction: deleteAction)
    }
    
    init(frame: CGRect, deleteBtnTitle: String, deleteAction: (() -> ())?) {
        super.init(frame: frame)
        self.deleteBtnTitle = deleteBtnTitle
        self.deleteAction = deleteAction
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    
    fileprivate func initialize() {
        if let view = Bundle.main.loadNibNamed("DeleteView", owner: self, options: nil)![0] as? UIView {
            
            self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: view.frame.width, height: view.frame.height))
            view.frame = self.frame
            view.isUserInteractionEnabled = true
            self.addSubview(view)
        }
        self.btnDelete.setTitle(deleteBtnTitle)
    }
    
    @IBAction func onDelete(_ sender: AnyObject) {
        deleteAction?()
    }
}


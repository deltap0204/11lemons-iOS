//
//  OptionPicker.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import PassKit


enum Option {
    case chose(item: OptionItemProtocol)
    case new
}

enum OptionsType {
    case addresses
    case paymentCards
    
    var addButtonTitle:String? {
        switch self {
        case .addresses:
            return "Add New Address"
        case .paymentCards:
            return "Add Card"
        }
    }
}


final class OptionPicker: UIAlertController {
    
    typealias OptionPickerCompletion = (_ selectedOption: Option?) -> Void
    
    fileprivate let optionItemList: [OptionItemProtocol]
    fileprivate let optionsType: OptionsType
    fileprivate let completion: OptionPickerCompletion?
    
    init(optionItemList: [OptionItemProtocol], optionsType: OptionsType, addingEnable: Bool = true, completion: @escaping OptionPickerCompletion) {
        self.optionItemList = optionItemList
        self.optionsType = optionsType
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        
        if addingEnable {
            let newCardAction = UIAlertAction(title: optionsType.addButtonTitle, style: UIAlertActionStyle.default) { [weak self] _ in
                self?.completion?(Option.new)
            }
            addAction(newCardAction)
        }
        
        for item in optionItemList {
            let action = UIAlertAction(title: item.label, style: UIAlertActionStyle.default) { [weak self, item] _ in
                self?.completion?(Option.chose(item: item))
            }
            if let image = item.image {
                action.setValue(image.withRenderingMode(.alwaysOriginal), forKey: "image")
            }
            addAction(action)
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { [weak self] _ in
            self?.completion?(nil)
        }
        addAction(cancelAction)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not implemented for AddressPicker")
    }
}

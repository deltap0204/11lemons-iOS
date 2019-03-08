//
//  ViewModel.swift
//  lemonapp
//
//  Created by mac-190-mini on 12/23/15.
//  Copyright © 2015 11lemons. All rights reserved.
//

protocol ViewModel {}

protocol ViewModelHolder {
    
    associatedtype ViewModelType = ViewModel
    var viewModel: ViewModelType? { get set }
}


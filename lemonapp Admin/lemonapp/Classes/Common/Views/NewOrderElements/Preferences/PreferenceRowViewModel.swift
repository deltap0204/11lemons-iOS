//
//  PreferenceRowViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/17/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit

protocol PreferenceRowUser {
    func changeValue(_ newOption: Any)
    func showModal()
    func getHeight() -> CGFloat
    func getCellIdentifier() -> String
    func getPreferenceName() -> String
    func bindTextLabelValue(_ textField: UILabel)
}

protocol PreferenceRowViewModelDelegate: class {
    func setupOrder(_ order: Order)
    func changeOrderDetailToAdd(_ order: Order)
    func showModal(_ alert: UIAlertController)
}

open class PreferenceRowViewModel {
    
    let StandarCellIdentifier = "PreferenceUserRowView"
    let StandarCellHeight = CGFloat(45)
    
    fileprivate let disposeBag = DisposeBag()
    let order: Order
    var changedUser: User?
    weak var delegate: PreferenceRowViewModelDelegate?
    var valueSelected = Observable<String>("")
    
    init(order: Order, delegate: PreferenceRowViewModelDelegate) {
        self.order = order
        self.delegate = delegate
        self.changedUser = order.createdBy
    }
    
    func getUserNameCreator() -> String {
        if let user = order.createdBy {
            return "\(user.firstName) \(user.lastName)"
        }
        return ""
    }
    
    func bindTextLabelValue(_ textField: UILabel) {
        valueSelected.value = getValue()
        valueSelected.bind(to: textField.bnd_text).dispose(in: disposeBag)
    }
    
    func showModal() {
        let alert = getAlert()
        delegate?.showModal(alert)
    }
    
    func getValue() -> String {
        fatalError("Must Override")
    }
    
    func getAlert() -> UIAlertController {
        fatalError("Must Override")
    }
    
    func getHeight() -> CGFloat {
        return CGFloat(StandarCellHeight)
    }
    
    func getCellIdentifier() -> String {
        return StandarCellIdentifier
    }
    
    //MARK: - Backend Update
    func updateOrder() {
        _ = LemonAPI.updateOrder(order: order, orderID: order.id).request().observeNext { [weak self] (result: EventResolver<Order>) in
            guard let strongSelf = self else { return }
            do {
                let newOrder = try result()
                strongSelf.delegate?.setupOrder(newOrder)
            } catch { }
        }
    }
    
    
    func updateUserPreferences(_ preferences: Preferences) {
        guard let changedUser = changedUser else { return }
        
        changedUser.preferences = preferences
        
        _ = LemonAPI.editProfile(user: changedUser).request().observeNext { (userResolver: EventResolver<User>) in
            do {
                let user = try userResolver()
                user.sync(changedUser)
                user.preferences.save()
            } catch let error {
                print(error)
            }
        }
    }
}

//
//  NewDepartmentViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 12/20/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond

protocol NewDepartmentViewModelDelegate: class {
    func showAlert(_ alert: UIAlertController)
    func goBackSeccefully()
    func segue(_ name:String)
}

final class NewDepartmentViewModel {
    
    fileprivate var imgNormalHasBeenChanged = false
    fileprivate var imgNormalToUpload: UIImage?
    fileprivate var imgSelectedHasBeenChanged = false
    fileprivate var imgSelectedToUpload: UIImage?
    fileprivate var isNormalImageUpdated = true
    fileprivate var isSelectedImageUpdated = true
    
    let isBusy = Observable<Bool>(false)
    let department: Service
    let isEditMode:Bool
    
    weak var delegate: NewDepartmentViewModelDelegate?
    
    init(department: Service, isEditMode: Bool, delegate: NewDepartmentViewModelDelegate) {
        self.department = department
        self.isEditMode = isEditMode
        self.delegate = delegate
    }
    
    func getName() -> String {
        return  isEditMode ? department.name : "Name"
    }
    
    func setName(_ name: String) {
        department.name = name
    }
    
    func getDescription() -> String {
        return isEditMode ? department.description : "See Price List"
    }
    
    func setDescription(_ desc: String) {
        department.description = desc
    }
    
    func getRoundPrice() -> Bool {
        return isEditMode ? department.roundPrice : false
    }
    
    func setRoundPrice(_ isRoundPrice: Bool) {
        department.roundPrice = isRoundPrice
    }
    
    func getPriceNearset() -> String {
        return isEditMode ? String(format: "%.2f", department.roundPriceNearest) : "0.00"
    }
    
    func setPriceNearset(_ price: Double) {
        department.roundPriceNearest = price
    }
    
    func getIsActive() -> Bool {
        return isEditMode ? department.active : true
    }
    
    func setIsActive(_ active: Bool) {
        department.active = active
    }
    
    func getIsBeta() -> Bool {
        let isBeta = department.isBeta ?? false
        return isEditMode ? isBeta : false
    }
    
    func setIsBeta(_ beta: Bool) {
        department.isBeta = beta
    }
    
    func getTaxable() -> Bool {
        return isEditMode ? department.taxable : true
    }
    
    func setTaxable(_ tax: Bool) {
        department.taxable = tax
    }
    
    func getRate() -> String {
        let rateText = department.rate == nil ? "" : "\(department.rate!)%"
        return isEditMode ? rateText : ""
    }
    
    func setRate(_ rate: Double?) {
        department.rate = rate ?? 0.0
    }
    
    func getActiveImage() -> String? {
        return isEditMode ? department.activeImage : nil
    }
    
    func getInactiveImage() -> String? {
        return isEditMode ? department.inactiveImage : nil
    }
    
    
    func saveImage(_ img: UIImage?, isNormalImage: Bool) {
        
        uploadImage(img, isNormalImage: isNormalImage)
        
        if isNormalImage {
            imgNormalHasBeenChanged = true
            imgNormalToUpload = img
            isNormalImageUpdated = false
        } else {
            imgSelectedHasBeenChanged = true
            imgSelectedToUpload = img
            isSelectedImageUpdated = false
        }
    }
    
    fileprivate func uploadImage(_ img: UIImage?, isNormalImage: Bool) {
        if let photo = img {
            ImageCache.saveImage(photo, url: "department_picture").observeNext {
                if let fileURL = $0() {
                    _ = LemonAPI.uploadDepartmentImage(imgURL: fileURL)
                        .request().observeNext { (resultResolver: EventResolver<String>) in
                            do {
                                let departmentPicture = try resultResolver()
                                if isNormalImage {
                                    self.department.inactiveImage = departmentPicture
                                    self.isNormalImageUpdated = true
                                } else {
                                    self.department.activeImage = departmentPicture
                                    self.isSelectedImageUpdated = true
                                }
                                print(departmentPicture)
                            } catch _ {
                            }
                    }
                }
            }
        }
    }
    
    func onDelete() {
        let alert = UIAlertController(title: "Are you sure want to delete this?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteService()
        }))
        delegate?.showAlert(alert)
    }
    
    fileprivate func deleteService() {
        isBusy.value = true
        _ = LemonAPI.deleteDepartment(departmentID: department.id).request().observeNext { [weak self] (_: EventResolver<String>) in
            guard let strongSelf = self else { return }
            strongSelf.isBusy.value = false
            strongSelf.delegate?.goBackSeccefully()
        }
    }
    
    func onSubmite() {
        if isSelectedImageUpdated && isNormalImageUpdated {
            isBusy.value = true
            if isEditMode {
                _ = LemonAPI.updateDepartment(department: department).request().observeNext { [weak self] (_: EventResolver<String>) in
                    guard let strongSelf = self else { return }
                    strongSelf.isBusy.value = false
                    strongSelf.delegate?.goBackSeccefully()
                }
            } else {
                _ = LemonAPI.createDepartment(department: department).request().observeNext { [weak self] (_: EventResolver<String>) in
                    guard let strongSelf = self else { return }
                    strongSelf.isBusy.value = false
                    strongSelf.delegate?.goBackSeccefully()
                }
            }
        } else {
            //TODO: show alert
        }
    }
    
}

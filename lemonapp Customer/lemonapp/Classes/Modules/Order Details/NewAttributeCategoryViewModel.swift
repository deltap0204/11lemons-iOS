//
//  NewAttributeCategoryViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 12/11/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond

protocol NewAttributeCategoryViewModelDelegate: class {
    func showAlert(_ alert: UIAlertController)
    func goBackSeccefully()
    func segue(_ name:String)
}

final class NewAttributeCategoryViewModel {
    
    var serviceRow: ServiceSelectedView?
    var attributeCategory: Category
    var isEditMode: Bool
    weak var delegate: NewAttributeCategoryViewModelDelegate?
    let isBusy = Observable<Bool>(false)
    
    var servicesRelated: [Product] = []
    var servicesRelatedHasChanged = false
    let departmentSelected = MutableObservableArray<Service>([])
    
    init (attributeCategory: Category?, isEditMode: Bool, delegate: NewAttributeCategoryViewModelDelegate) {
        self.attributeCategory = attributeCategory ?? Category(id: 0)
        self.isEditMode = isEditMode
        self.delegate = delegate
        departmentSelected.observeNext { [weak self] departmentSelected in
            guard let strongSelf = self else { return }
            strongSelf.serviceRow?.numberOfItems.value = departmentSelected.dataSource.array.count
        }
        if isEditMode {
            getServiceRelation()
        }
    }
    
    func getName() -> String {
        return isEditMode ? attributeCategory.name : ""
    }
    
    func setName(_ name: String?) {
        attributeCategory.name = name ?? ""
    }
    
    func getItemizeOnReceipt() -> Bool {
        if isEditMode {
            let required = attributeCategory.itemizeOnReceipt ?? false
            return required
        } else {
            attributeCategory.itemizeOnReceipt = true
            return true
        }
    }
    
    func setItemizeOnReceipt(_ value: Bool) {
        attributeCategory.itemizeOnReceipt = value
    }
    
    func getRequired() -> Bool {
        if isEditMode {
            let required = attributeCategory.required ?? false
            return required
        } else {
            attributeCategory.required = true
            return true
        }
    }
    
    func setRequired(_ value: Bool) {
        attributeCategory.required = value
    }
    
    func getAllowMultiple() -> Bool {
        if !isEditMode {
            self.attributeCategory.allowMultipleValues = true
        }
        guard let allowMultiple = attributeCategory.allowMultipleValues else { return false }
        return isEditMode ? allowMultiple : false
    }
    
    func setAllowMultiple(_ value: Bool) {
        attributeCategory.allowMultipleValues = value
    }
    
    func getTemporaryAttribute() -> Bool {
        guard let temporaryAttribute = attributeCategory.temporaryAttribute else { return false }
        return isEditMode ? temporaryAttribute : false
    }
    
    func setTemporaryAttribute(_ value: Bool) {
        attributeCategory.temporaryAttribute = value
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
        _ = LemonAPI.deleteCategory(categoryID: attributeCategory.id).request().observeNext { [weak self] (_: EventResolver<String>) in
            guard let strongSelf = self else { return }
            strongSelf.isBusy.value = false
            strongSelf.delegate?.goBackSeccefully()
        }
    }
    
    //MARK: Actions
    func selectServices() {
        delegate?.segue(StoryboardSegueIdentifier.ServiceDepartmentSelection.rawValue)
    }
    
    func submitCategory() {
        guard validation() else {
            delegate?.showAlert(getAlertError())
            return
        }
        isBusy.value = true
        if isEditMode {
            if servicesRelatedHasChanged {
                removeRelations()
                addRelations()
            }
            
            _ = LemonAPI.updateAttributeCategory(category: attributeCategory).request().observeNext  { [weak self] (_: EventResolver<String>) in
                guard let strongSelf = self else { return }
                strongSelf.isBusy.value = false
                strongSelf.delegate?.goBackSeccefully()
            }
        } else {
            _ = LemonAPI.createAttributeCategory(category: attributeCategory).request().observeNext {  [weak self] (result: EventResolver<Category>) in
                guard let strongSelf = self else { return }
                do {
                    let category = try result()
                    strongSelf.departmentSelected.array.forEach { service in
                        _ = LemonAPI.addRelationBtwCategoryAndService(categoryID: category.id, serviceID:service.id ).request().observeNext { (_: EventResolver<String>) in }
                    }
                } catch { }
                strongSelf.isBusy.value = false
                strongSelf.delegate?.goBackSeccefully()
            }
        }
    }

    fileprivate func validation() -> Bool {
        let attributeCategoryPlaceholder = Category(id: 0)
        guard !attributeCategory.name.isEmpty && attributeCategory.name != attributeCategoryPlaceholder.name  else { return false }
        if isEditMode && !servicesRelatedHasChanged {
            return true
        }
        guard departmentSelected.count > 0 else { return false }
        
        return true
    }
    
    fileprivate func getAlertError() -> UIAlertController {
        let alertController = UIAlertController(title: "", message: "Please, complete all fields", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        return alertController
    }
    
    fileprivate func getServiceRelation() {
        _ = LemonAPI.getRelationBtwCategoryAndService(categoryID: attributeCategory.id).request().observeNext { [weak self] (result: EventResolver<[Product]>) in
            guard let strongSelf = self else { return }
            do {
                let services = try result()
                strongSelf.servicesRelated = services
                strongSelf.serviceRow?.numberOfItems.value = strongSelf.servicesRelated.count
            } catch { }
        }
    }
    
    fileprivate func removeRelations() {
        var serviceToRemove:[Product] = []
        servicesRelated.forEach { product in
            if !departmentSelected.array.contains( where: {$0.id == product.id} )
            {
                serviceToRemove.append(product)
            }
        }
        serviceToRemove.forEach { product in
            _ = LemonAPI.deleteRelationBtwCategoryAndService(categoryID: attributeCategory.id, serviceID:product.id ).request().observeNext { (_: EventResolver<String>) in }
        }
    }
    
    fileprivate func addRelations() {
        var serviceToAdd:[Service] = []
        departmentSelected.array.forEach { service in
            if !servicesRelated.contains( where: {$0.id == service.id} )
            {
                serviceToAdd.append(service)
            }
        }
        serviceToAdd.forEach { service in
            _ = LemonAPI.addRelationBtwCategoryAndService(categoryID: attributeCategory.id, serviceID:service.id ).request().observeNext { (_: EventResolver<String>) in }
        }
    }
}

extension NewAttributeCategoryViewModel: DepartmentAndServiceSelectionDelegate {
    func finalSelection(_ departments: [Service]) {
        servicesRelatedHasChanged = true
        departmentSelected.replace(with: departments)
    }
}




//
//  DepartmentSelectionViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/4/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond

protocol DepartmentSelectionViewModelDelegate: class {
    func segue(_ name: String)
    func goBack()
}

final class DepartmentSelectionViewModel: ViewModel {
    
    let departmentCellViewModels = MutableObservableArray<DepartmentSelectionCellModel>()
    fileprivate(set) var departmentSelected: Service?
    let serviceSelected: [Product]?
    
    
    weak var delegate: DepartmentSelectionViewModelDelegate?
    weak var selectionDelegate: DepartmentAndServiceSelectionDelegate?
    
    init(delegate: DepartmentSelectionViewModelDelegate, selectionDelegate: DepartmentAndServiceSelectionDelegate, serviceSelected: [Product]?) {
        self.delegate = delegate
        self.selectionDelegate = selectionDelegate
        self.serviceSelected = serviceSelected
        self.updateDepartmentList({})
    }
    
    func updateDepartmentList(_ completion: @escaping () -> Void) {
        _ = LemonAPI.getDepartmentsAll().request().observeNext { [weak self] (result: EventResolver<[Service]>) in
            do {
                completion()
                let departments = try result()
                self?.refreshDepartmentList(departments.sorted { $0.active && !$1.active })
            } catch { }
        }
    }
    
    fileprivate func refreshDepartmentList(_ newDepartments: [Service]) {
        DispatchQueue.main.async {
            self.departmentCellViewModels.removeAll()
            newDepartments.forEach { [weak self] department in
                guard let strongSelf = self else { return }
                
                let departmentVM = DepartmentSelectionCellModel(department: department)
                
                if let serviceSelected = strongSelf.serviceSelected {
                    if serviceSelected.contains(where: { $0.id == department.id}) {
                        departmentVM.department.isSelected = true
                        departmentVM.numberOfServicesSelected.value = departmentVM.department.typesOfService!.count
                    } else {
                        if let typesOfServices = department.typesOfService {
                            typesOfServices.forEach{ service in
                                if serviceSelected.contains(where: { $0.id == service.id}) {
                                    departmentVM.department.typesOfService!.filter({$0.id == service.id})[0].isSelected = true
                                    departmentVM.numberOfServicesSelected.value = departmentVM.numberOfServicesSelected.value + 1
                                }
                            }
                        }
                    }
                }
                
                strongSelf.departmentCellViewModels.append(departmentVM)
            }
        }
    }
    
    func departmentSelected(_ position: Int) {
        if position < departmentCellViewModels.count {
            departmentSelected = departmentCellViewModels.array[position].department
            delegate?.segue(StoryboardSegueIdentifier.ServiceSelection.rawValue)
        }
    }
    
    //MARK: Actions
    func clearSelections() {
        departmentCellViewModels.array.forEach {
            $0.clear()
        }
    }
    
    func selectAll() {
        departmentCellViewModels.array.forEach {
            $0.selectAll()
        }
    }
    
    func done() {
        selectionDelegate?.finalSelection(getServiceSelected())
        delegate?.goBack()
    }
    
    func cancel() {
        delegate?.goBack()
    }
    
    fileprivate func getServiceSelected() -> [Service] {
        var selectedServices:[Service] = []
        
        departmentCellViewModels.array.forEach { departmentVM in
            let department = departmentVM.department
            if department.isSelected {
                department.typesOfService?.forEach{
                    $0.isSelected = true
                    selectedServices.append($0)
                }
            }
            department.typesOfService?.filter {$0.isSelected}.forEach {
                selectedServices.append($0)
            }
        }

        return selectedServices
    }
}

extension DepartmentSelectionViewModel: ServiceSelectionDelegate {
    func finalSelection(_ department: Service, services: [Service]) {
        departmentCellViewModels.array.filter{$0.department.id == department.id}.forEach{
            $0.department.typesOfService = services
            $0.numberOfServicesSelected.value = services.filter{$0.isSelected}.count
        }
    }
}

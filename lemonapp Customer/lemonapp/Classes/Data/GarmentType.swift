//
//  GarmentType.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import CoreData

final class GarmentType {
    
    let id: Int
    let type: String?
    let description: String?
    
    fileprivate let _dataModel: GarmentTypeModel
    
    init(
        id: Int,
        type: String?,
        description: String?,
        dataModel: GarmentTypeModel? = nil) {
            self.id = id
            self.type = type
            self.description = description
            self._dataModel = dataModel ?? LemonCoreDataManager.findWithId(id) ?? GarmentTypeModel()
            syncDataModel()
    }
    
    convenience init(typeModel: GarmentTypeModel) {
        self.init(
            id: typeModel.id.intValue,
            type: typeModel.type,
            description: typeModel.descr,
            dataModel: typeModel
        )
    }
    
}

extension GarmentType: Hashable {
    
    var hashValue: Int { return id }
}

func == (left: GarmentType, right: GarmentType) -> Bool {
    return left.id == right.id
}

extension GarmentType: DataModelWrapper {
    
    var dataModel: NSManagedObject {
        return _dataModel
    }
    
    func syncDataModel() {
        _dataModel.id = self.id as NSNumber
        _dataModel.type = self.type
        _dataModel.descr = self.description
        saveDataModelChanges()
    }
}

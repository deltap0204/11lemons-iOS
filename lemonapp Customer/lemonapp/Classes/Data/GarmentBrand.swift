//
//  GarmentBrand.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import CoreData

final class GarmentBrand {
    
    let id: Int
    let name: String?
    let description: String?
    
    fileprivate let _dataModel: GarmentBrandModel
    
    init(
        id: Int,
        name: String?,
        description: String?,
        dataModel: GarmentBrandModel? = nil) {
        self.id = id
            self.name = name
            self.description = description
            self._dataModel = dataModel ?? LemonCoreDataManager.findWithId(id) ?? GarmentBrandModel()
            syncDataModel()
    }    
    
    convenience init(brandModel: GarmentBrandModel) {
        self.init(
            id: brandModel.id.intValue,
            name: brandModel.name,
            description: brandModel.descr,
            dataModel:brandModel
        )
    }
}

extension GarmentBrand: Hashable {
    
    var hashValue: Int { return id }
}

func == (left: GarmentBrand, right: GarmentBrand) -> Bool {
    return left.id == right.id
}

extension GarmentBrand: DataModelWrapper {
    
    var dataModel: NSManagedObject {
        return _dataModel
    }
    
    func syncDataModel() {
        _dataModel.id = self.id as NSNumber
        _dataModel.descr = self.description
        _dataModel.name = self.name
        saveDataModelChanges()
    }
}

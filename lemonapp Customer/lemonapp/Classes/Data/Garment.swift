//
//  Garment.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import CoreData
import Bond

final class Garment: Equatable {
    
    let id: Int
    let userId: Int
    let description: String?
    let imageName: String?
    var brand: GarmentBrand?
    var type: GarmentType?
    let viewed = Observable(false)
    
    fileprivate let _dataModel: GarmentModel
    
    init(id: Int,
        userId: Int,
        description: String?,
        imageName: String?,
        brand: GarmentBrand? = nil,
        type: GarmentType? = nil,
        dataModel: GarmentModel? = nil) {
            self.id = id
            self.userId = userId
            self.description = description
            self.imageName = imageName
            self.brand = brand
            self.type = type
            self._dataModel = dataModel ?? LemonCoreDataManager.findWithId(id) ?? GarmentModel()
            self.viewed.value = _dataModel.viewed
            syncDataModel()
            viewed.skip(first: 1).observeNext { [weak self]_ in
                self?.syncDataModel()
            }
    }
    
    convenience init(garmentModel: GarmentModel) {
        self.init(id: garmentModel.id.intValue,
            userId: garmentModel.userId.intValue,
            description: garmentModel.descr,
            imageName: garmentModel.imageName,
            dataModel: garmentModel
        )
        if let typeModel = garmentModel.type {
            self.type = GarmentType(typeModel: typeModel)
        }
        if let brandModel = garmentModel.brand {
            self.brand = GarmentBrand(brandModel: brandModel)
        }
    }
}

func == (lft: Garment, rgh: Garment) -> Bool {
    return lft.id == rgh.id
}

extension Garment: DataModelWrapper {
    
    var dataModel: NSManagedObject {
        return _dataModel
    }
    
    func bindModels() {
        _dataModel.brand = brand?.dataModel as? GarmentBrandModel
        _dataModel.type = type?.dataModel as? GarmentTypeModel
        saveDataModelChanges()
    }
    
    func syncDataModel() {
        _dataModel.id = NSNumber(value: self.id)
        _dataModel.descr = self.description
        _dataModel.imageName = self.imageName
        _dataModel.viewed = self.viewed.value
        _dataModel.userId = NSNumber(value: self.userId)
        saveDataModelChanges()
    }
}

//
//  Service.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class Service {
    
    var id: Int
    var name: String = ""
    var description: String = ""
    var active: Bool = false
    var taxable: Bool = false
    var isBeta: Bool?
    var rate: Double?
    var price: Double = 0.0
    var priceBasedOn: String = ""
    var isSelected: Bool = false
    var parentID: Int = 0
    var activeImage: String = ""
    var inactiveImage: String = ""
    var typesOfService: [Service]?
    var unitType: String = ""
    var roundPriceNearest: Double = 0.0
    var roundPrice: Bool = false
    
    fileprivate var _dataModel: ServiceModel = ServiceModel()
    
    init(id: Int) {
        self.id = id
    }
    
    convenience init(serviceModel: ServiceModel) {
        self.init(id: serviceModel.id.intValue)
        name = serviceModel.name
        description = serviceModel.descr
        active = serviceModel.active
        taxable = serviceModel.taxable
        isBeta = serviceModel.isBeta
        rate = serviceModel.rate.doubleValue
        price = serviceModel.price.doubleValue
        priceBasedOn = serviceModel.priceBasedOn == "Order Weight" ? "Pound" : serviceModel.priceBasedOn
        isSelected = serviceModel.isSelected
        parentID = serviceModel.parentID.intValue
        activeImage = serviceModel.activeImage
        inactiveImage = serviceModel.inactiveImage
        typesOfService = serviceModel.typesOfService.map { Service(serviceModel: $0) }
        unitType = serviceModel.unitType
        roundPriceNearest = serviceModel.roundPriceNearest.doubleValue
        roundPrice = serviceModel.roundPrice
        
        _dataModel = serviceModel
    }
    
    func sync(_ service: Service) {
        name = service.name
        description = service.description
        active = service.active
        taxable = service.taxable
        isBeta = service.isBeta
        rate = service.rate
        price = service.price
        priceBasedOn = service.priceBasedOn
        isSelected = service.isSelected
        parentID = service.parentID
        activeImage = service.activeImage
        inactiveImage = service.inactiveImage
        unitType = service.unitType
        roundPriceNearest = service.roundPriceNearest
        roundPrice = service.roundPrice
        
        typesOfService = service.typesOfService
        syncDataModel()
    }
}

extension Service: DataModelWrapper {
    
    var dataModel: NSManagedObject {
        return _dataModel
    }
    
    func syncDataModel() {
        _dataModel.id = NSNumber(value: id as Int)
        _dataModel.name = name
        _dataModel.descr = description
        _dataModel.active = active
        _dataModel.taxable = taxable
        _dataModel.isBeta = isBeta ?? false
        _dataModel.rate = NSNumber(value: (rate ?? 0.0) as Double)
        _dataModel.price = NSNumber(value: price as Double)
        _dataModel.priceBasedOn = priceBasedOn
        _dataModel.isSelected = isSelected
        _dataModel.parentID = NSNumber(value: parentID as Int)
        _dataModel.activeImage = activeImage
        _dataModel.inactiveImage = inactiveImage
        _dataModel.unitType = unitType
        _dataModel.roundPriceNearest = NSNumber(value: roundPriceNearest as Double)
        _dataModel.roundPrice = roundPrice
        
        typesOfService?.forEach {
            if let serviceModel = $0.dataModel as? ServiceModel, !_dataModel.typesOfService.contains(serviceModel) {
                if let exist = try? LemonCoreDataManager.fetch(ServiceModel.self).contains(serviceModel) {
                    if !exist {
                        LemonCoreDataManager.insert(false, objects: serviceModel)
                    }
                }
                _dataModel.typesOfService.insert(serviceModel)
            }
        }
    }
}
extension Service: Equatable {
    static func == (lhs: Service, rhs: Service) -> Bool {
        return lhs.id == rhs.id
    }
}

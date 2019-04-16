//
//  ServiceEntity.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//


import Foundation
import RealmSwift
public class ServiceEntity: Object, RealmOptionalType {
    override public static func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var descriptions = ""
    @objc dynamic var active = false
    @objc dynamic var taxable = false
    let isBeta = RealmOptional<Bool>()
    let rate = RealmOptional<Double>()
    @objc dynamic var price: Double = 0.0
    @objc dynamic var priceBasedOn = ""
    @objc dynamic var isSelected = false
    @objc dynamic var parentID = 0
    @objc dynamic var activeImage = ""
    @objc dynamic var inactiveImage = ""
    let typesOfService = List<ServiceEntity>()
    @objc dynamic var unitType = ""
    @objc dynamic var roundPriceNearest: Double = 0.0
    @objc dynamic var roundPrice = false
    
    static func create(with service: Service) -> ServiceEntity {
        let serviceEntity = ServiceEntity()
        serviceEntity.id = service.id
        serviceEntity.name = service.name
        serviceEntity.descriptions = service.description
        serviceEntity.active = service.active
        serviceEntity.taxable = service.taxable
        serviceEntity.isBeta.value = service.isBeta
        serviceEntity.rate.value = service.rate
        serviceEntity.price = service.price
        serviceEntity.priceBasedOn = service.priceBasedOn
        serviceEntity.isSelected = service.isSelected
        serviceEntity.parentID = service.parentID
        serviceEntity.activeImage = service.activeImage
        serviceEntity.inactiveImage = service.inactiveImage
        serviceEntity.typesOfService.removeAll()
        let services = service.typesOfService?.compactMap { ServiceEntity.create(with: $0) } ?? []
        serviceEntity.typesOfService.append(objectsIn: services)
        serviceEntity.unitType = service.unitType
        serviceEntity.roundPriceNearest = service.roundPriceNearest
        serviceEntity.roundPrice = service.roundPrice
        return serviceEntity
    }
}

func == (lft: ServiceEntity, rgh: ServiceEntity) -> Bool {
    return lft.id == rgh.id
}


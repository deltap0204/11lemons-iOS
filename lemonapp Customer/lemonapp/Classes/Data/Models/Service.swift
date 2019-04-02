//
//  Service.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


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
    
    init(id: Int) {
        self.id = id
    }
    
    init(entity: ServiceEntity) {
        self.id = entity.id
        self.name = entity.name
        self.description = entity.descriptions
        self.active = entity.active
        self.taxable = entity.taxable
        self.isBeta = entity.isBeta.value
        self.rate = entity.rate.value
        self.price = entity.price
        self.priceBasedOn = entity.priceBasedOn
        self.isSelected = entity.isSelected
        self.parentID = entity.parentID
        self.activeImage = entity.activeImage
        self.inactiveImage = entity.inactiveImage
        self.typesOfService = entity.typesOfService.compactMap({Service(entity: $0)})
        self.unitType = entity.unitType
        self.roundPriceNearest = entity.roundPriceNearest
        self.roundPrice = entity.roundPrice
    }
}

extension Service: Equatable {
    static func == (lhs: Service, rhs: Service) -> Bool {
        return lhs.id == rhs.id
    }
}

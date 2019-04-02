//
//  Garment.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//


import Bond

final class Garment: Equatable {
    
    let id: Int
    let userId: Int
    let description: String?
    let imageName: String?
    var brand: GarmentBrand?
    var type: GarmentType?
    let viewed = Observable(false)

    
    init(id: Int,
        userId: Int,
        description: String?,
        imageName: String?,
        brand: GarmentBrand? = nil,
        type: GarmentType? = nil) {
            self.id = id
            self.userId = userId
            self.description = description
            self.imageName = imageName
            self.brand = brand
            self.type = type
//            self.viewed.value = _dataModel.viewed
    }

}

func == (lft: Garment, rgh: Garment) -> Bool {
    return lft.id == rgh.id
}

//
//  GarmentBrand.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//



final class GarmentBrand {
    
    let id: Int
    let name: String?
    let description: String?
    
    init(
        id: Int,
        name: String?,
        description: String?) {
        self.id = id
            self.name = name
            self.description = description
    }    
    
    
}

extension GarmentBrand: Hashable {
    
    var hashValue: Int { return id }
}

func == (left: GarmentBrand, right: GarmentBrand) -> Bool {
    return left.id == right.id
}


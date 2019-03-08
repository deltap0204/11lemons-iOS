//
//  GarmentType.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//



final class GarmentType {
    
    let id: Int
    let type: String?
    let description: String?
    
    init(
        id: Int,
        type: String?,
        description: String?) {
            self.id = id
            self.type = type
            self.description = description
    }

}

extension GarmentType: Hashable {
    
    var hashValue: Int { return id }
}

func == (left: GarmentType, right: GarmentType) -> Bool {
    return left.id == right.id
}


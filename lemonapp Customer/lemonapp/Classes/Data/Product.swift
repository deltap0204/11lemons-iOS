//
//  Product.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


final class Product: Equatable {
    
    var id: Int
    var name: String
    var description: String
    var isActive: Bool
    var price: Float
    var taxable: Bool
    var useWeight: Bool
    var parentId: Int
    var subproducts = [Product]()
    
    init (id: Int,
        name: String,
        description: String,
        isActive: Bool,
        price: Float,
        taxable: Bool,
        useWeight: Bool,
        parentId: Int) {
            
            self.id = id
            self.name = name
            self.description = description
            self.isActive = isActive
            self.price = price
            self.taxable = taxable
            self.useWeight = useWeight
            self.parentId = parentId
    }

    init(entity: ProductEntity) {
        self.id = entity.id
        self.name = entity.name
        self.description = entity.descriptions
        self.isActive = entity.isActive
        self.price = entity.price
        self.taxable = entity.taxable
        self.useWeight = entity.useWeight
        self.parentId = entity.parentId
        self.subproducts = entity.subproducts.compactMap({ Product(entity: $0)})
    }
    
    static func groupingProducts(_ products: [Product]) -> [Product] {
        let groupedProducts = products.compactMap { $0.parentId == 0 ? $0 : nil }
        var productsDict = [Int: Product]()
        groupedProducts.forEach { productsDict[$0.id] = $0 }
        products.forEach { if $0.parentId != 0 {  productsDict[$0.parentId]?.subproducts.append($0) } }
        return groupedProducts
    }
}


func == (left: Product, right: Product) -> Bool {
    return left.id == right.id
}

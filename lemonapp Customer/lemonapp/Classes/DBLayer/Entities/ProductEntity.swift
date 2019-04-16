//
//  ProductEntity.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//


import Foundation
import RealmSwift
public class ProductEntity: Object, RealmOptionalType {
    override public static func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var descriptions = ""
    @objc dynamic var isActive = false
    @objc dynamic var price: Float = 0.0
    @objc dynamic var taxable = false
    @objc dynamic var useWeight = false
    @objc dynamic var parentId = 0
    let subproducts = List<ProductEntity>()
    
    static func create(with product: Product) -> ProductEntity {
        let productEntity = ProductEntity()
        productEntity.id = product.id
        productEntity.name = product.name
        productEntity.descriptions = product.description
        productEntity.isActive = product.isActive
        productEntity.price = product.price
        productEntity.taxable = product.taxable
        productEntity.useWeight = product.useWeight
        productEntity.parentId = product.parentId
        productEntity.subproducts.removeAll()
        let subProducts = product.subproducts.compactMap( {ProductEntity.create(with: $0)}) 
        productEntity.subproducts.append(objectsIn: subProducts)
        return productEntity
    }
}



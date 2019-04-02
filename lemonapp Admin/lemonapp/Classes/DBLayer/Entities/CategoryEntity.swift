//
//  CategoryEntity.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 06/03/2019.
//  Copyright © 2019 11lemons. All rights reserved.
//

import Foundation
import RealmSwift
public class CategoryEntity: Object, RealmOptionalType {
    @objc dynamic var id = 0
    @objc dynamic var name: String = ""
    @objc dynamic var descriptions: String = ""
    @objc dynamic var active: Bool = false
    let maxAllowed = RealmOptional<Int>()
    let required = RealmOptional<Bool>()
    @objc dynamic var image: String = ""
    let itemizeOnReceipt = RealmOptional<Bool>()
    let allowMultipleValues = RealmOptional<Bool>()
    let temporaryAttribute = RealmOptional<Bool>()
    @objc dynamic var singleProduct: Bool = false
    @objc dynamic var pounds: Bool = false
    @objc dynamic var dollars: Bool = false
    @objc dynamic var months: Bool = false
    @objc dynamic var hours: Bool = false
    @objc dynamic var other: Bool = false
    @objc dynamic var deleted: Bool = false
    let attributes = List<AttributeEntity>()
    
    static func create(with category: Category) -> CategoryEntity {
        let categoryEntity = CategoryEntity()
        categoryEntity.id = category.id
        categoryEntity.name = category.name
        categoryEntity.descriptions = category.description
        categoryEntity.active = category.active
        categoryEntity.maxAllowed.value = category.maxAllowed
        categoryEntity.required.value = category.required
        categoryEntity.image = category.image
        categoryEntity.itemizeOnReceipt.value = category.itemizeOnReceipt
        categoryEntity.allowMultipleValues.value = category.allowMultipleValues
        categoryEntity.temporaryAttribute.value = category.temporaryAttribute
        categoryEntity.singleProduct = category.singleProduct
        categoryEntity.pounds = category.pounds
        categoryEntity.dollars = category.dollars
        categoryEntity.months = category.months
        categoryEntity.hours = category.hours
        categoryEntity.other = category.other
        categoryEntity.deleted = category.deleted
        categoryEntity.attributes.removeAll()
        let attributes = (category.attributes?.compactMap { AttributeEntity.create(with: $0) }) ?? []
        categoryEntity.attributes.append(objectsIn: attributes)
        return categoryEntity
    }
}


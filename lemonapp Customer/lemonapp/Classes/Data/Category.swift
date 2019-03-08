//
//  Category.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

final class Category: Copying {
    
    var id: Int
    var name: String = ""
    var description: String = ""
    var active: Bool = false
    var maxAllowed: Int?
    var required: Bool?
    var image: String = ""
    var itemizeOnReceipt: Bool?
    var allowMultipleValues: Bool?
    var temporaryAttribute: Bool?
    var singleProduct: Bool = false
    var pounds: Bool = false
    var dollars: Bool = false
    var months: Bool = false
    var hours: Bool = false
    var other: Bool = false
    var deleted: Bool = false
    var attributes: [Attribute]?
    
    fileprivate var _dataModel: CategoryModel = CategoryModel()
    
    init(id: Int) {
        self.id = id
    }
    
    convenience init(categoryModel: CategoryModel) {
        self.init(id: categoryModel.id.intValue)
        name = categoryModel.name
        description = categoryModel.descr
        active = categoryModel.active
        maxAllowed = categoryModel.maxAllowed?.intValue
        required = categoryModel.required
        image = categoryModel.image
        itemizeOnReceipt = categoryModel.itemizeOnReceipt
        allowMultipleValues = categoryModel.allowMultipleValues
        singleProduct = categoryModel.singleProduct
        pounds = categoryModel.pounds
        dollars = categoryModel.dollars
        months = categoryModel.months
        hours = categoryModel.hours
        other = categoryModel.other
        deleted = categoryModel.isDelet
        temporaryAttribute = categoryModel.temporaryAttribute
        attributes = categoryModel.attributes.map { Attribute(attributeModel: $0) }
        _dataModel = categoryModel
    }
    
    convenience init (original: Category) {
        self.init (id: original.id,
        name:  original.name,
        description: original.description,
        active: original.active,
        maxAllowed: original.maxAllowed,
        required: original.required,
        image: original.image,
        itemizeOnReceipt: original.itemizeOnReceipt,
        allowMultipleValues: original.allowMultipleValues,
        temporaryAttribute: original.temporaryAttribute,
        singleProduct: original.singleProduct,
        pounds: original.pounds,
        dollars: original.dollars,
        months: original.months,
        hours: original.hours,
        other: original.other,
        deleted: original.deleted,
        attributes: original.attributes)
        
    }
    init (id: Int, name: String = "", description: String = "", active: Bool = false, maxAllowed: Int?, required: Bool?, image: String = "", itemizeOnReceipt: Bool?, allowMultipleValues: Bool?, temporaryAttribute: Bool?, singleProduct: Bool = false, pounds: Bool = false, dollars: Bool = false, months: Bool = false, hours: Bool = false, other: Bool = false, deleted: Bool = false, attributes: [Attribute]?) {
        self.id = id
        self.name = name
        self.description = description
        self.active = active
        self.maxAllowed = maxAllowed
        self.required = required
        self.image = image
        self.itemizeOnReceipt = itemizeOnReceipt
        self.allowMultipleValues = allowMultipleValues
        self.temporaryAttribute = temporaryAttribute
        self.singleProduct = singleProduct
        self.pounds = pounds
        self.dollars = dollars
        self.months = months
        self.hours = hours
        self.other = other
        self.deleted = deleted
        self.attributes = attributes
    }
    
    
    func sync(_ category: Category) {
        name = category.name
        description = category.description
        active = category.active
        maxAllowed = category.maxAllowed
        required = category.required
        image = category.image
        itemizeOnReceipt = category.itemizeOnReceipt
        allowMultipleValues = category.allowMultipleValues
        temporaryAttribute = category.temporaryAttribute
        singleProduct = category.singleProduct
        pounds = category.pounds
        dollars = category.dollars
        months = category.months
        hours = category.hours
        other = category.other
        deleted = category.deleted
        attributes = category.attributes
        syncDataModel()
    }
}

extension Category: DataModelWrapper {
    
    var dataModel: NSManagedObject {
        return _dataModel
    }
    
    func syncDataModel() {
        _dataModel.id = NSNumber(value: id as Int)
        _dataModel.name = name
        _dataModel.descr = description
        _dataModel.active = active
        _dataModel.maxAllowed = maxAllowed as! NSNumber
        _dataModel.required = required ?? false
        _dataModel.image = image
        _dataModel.itemizeOnReceipt = itemizeOnReceipt ?? false
        _dataModel.allowMultipleValues = allowMultipleValues ?? false
        _dataModel.temporaryAttribute = temporaryAttribute ?? false
        _dataModel.singleProduct = singleProduct
        _dataModel.pounds = pounds
        _dataModel.dollars = dollars
        _dataModel.months = months
        _dataModel.hours = hours
        _dataModel.other = other
        _dataModel.isDelet = deleted
        
        attributes?.forEach {
            if let attributeModel = $0.dataModel as? AttributeModel, !_dataModel.attributes.contains(attributeModel) {
                if let exist = try? LemonCoreDataManager.fetch(AttributeModel.self).contains(attributeModel) {
                    if !exist {
                        LemonCoreDataManager.insert(false, objects: attributeModel)
                    }
                }
                _dataModel.attributes.insert(attributeModel)
            }
        }
    }
}

//
//  Product.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData

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
    fileprivate var _dataModel: ProductModel
    
    init (id: Int,
        name: String,
        description: String,
        isActive: Bool,
        price: Float,
        taxable: Bool,
        useWeight: Bool,
        parentId: Int,
        dataModel: ProductModel? = nil) {
            
            self.id = id
            self.name = name
            self.description = description
            self.isActive = isActive
            self.price = price
            self.taxable = taxable
            self.useWeight = useWeight
            self.parentId = parentId
            
            self._dataModel = dataModel ?? LemonCoreDataManager.findWithId(id) ?? ProductModel(id: NSNumber(value: id as Int),
                name: name,
                description: description,
                isActive: isActive,
                price: NSNumber(value: price as Float),
                taxable: taxable,
                useWeight: useWeight,
                parentId: NSNumber(value: parentId as Int))

            syncDataModel()
    }
    
    convenience init(productModel: ProductModel) {
        self.init(id: productModel.id.intValue,
            name: productModel.name,
            description: productModel.descr,
            isActive: productModel.isActive,
            price: productModel.price.floatValue,
            taxable: productModel.taxable,
            useWeight: productModel.useWeight,
            parentId: productModel.parentId.intValue,
            dataModel: productModel)
    }
    
    static func groupingProducts(_ products: [Product]) -> [Product] {
        let groupedProducts = products.flatMap { $0.parentId == 0 ? $0 : nil }
        var productsDict = [Int: Product]()
        groupedProducts.forEach { productsDict[$0.id] = $0 }
        products.forEach { if $0.parentId != 0 {  productsDict[$0.parentId]?.subproducts.append($0) } }
        return groupedProducts
    }
}

extension Product: DataModelWrapper {
    
    var dataModel: NSManagedObject {
        return _dataModel
    }
    
    func syncDataModel() {
        _dataModel.id = NSNumber(value: self.id as Int)
        _dataModel.name = self.name
        _dataModel.descr = self.description
        _dataModel.isActive = self.isActive
        _dataModel.price = NSNumber(value: self.price as Float)
        _dataModel.taxable = self.taxable
        _dataModel.useWeight = self.useWeight
        _dataModel.parentId = NSNumber(value: self.parentId as Int)
        saveDataModelChanges()
    }
}

func == (left: Product, right: Product) -> Bool {
    return left.id == right.id
}

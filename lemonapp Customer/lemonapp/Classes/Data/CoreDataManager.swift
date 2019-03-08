//
//  CoreDataManager.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import CoreData
import JSQCoreDataKit
import Crashlytics

var LemonCoreDataManager: CoreDataManager! = nil// = CoreDataManager(dataModel: CoreDataModel(name: "lemonapp"))

public func initLemonCoreDataManager(completion: @escaping () -> ()) {
    LemonCoreDataManager = CoreDataManager(dataModel: CoreDataModel(name: "lemonapp"), completion: completion)
}


protocol DataFetcher {
    var context: NSManagedObjectContext { get }
}

protocol ModelNameProvider: class {
    static var modelName: String { get }
}

protocol ModelIdProvider: class {
    var id: Int64 { get }
    static var idFieldName: String { get }
}

extension ChildContext: DataFetcher {
    var context: NSManagedObjectContext { return self }
}

protocol DataModelWrapper {
    
    var dataModel: NSManagedObject { get }
    func syncDataModel()
}

extension DataModelWrapper {
    
    func saveDataModel() {
        LemonCoreDataManager.insert(objects: dataModel)
    }
    
    func saveDataModelChanges() {
        objc_sync_enter(LemonCoreDataManager.context)
        if LemonCoreDataManager.context.hasChanges {
            LemonCoreDataManager.saveChanges()
        }
        objc_sync_exit(LemonCoreDataManager.context)
    }
}

extension DataFetcher {
    
    func fetchAsync<T: NSManagedObject>(_ classType: T.Type, orderByName name: String? = nil, ascending: Bool = true, completion: ((() throws -> [T]?)->())? = nil) where T: ModelNameProvider  {
        let context = self.context
        //let request = FetchRequest<T>(entity: entity(name: T.modelName, context: context))
        let request = NSFetchRequest<T>(entityName: T.modelName)
        if let name = name {
            request.sortDescriptors = [NSSortDescriptor(key: name, ascending: ascending)]
        }
        context.perform {
            do {
                let result = try context.fetch(request)
                DispatchQueue.main.async {
                    completion?( { return result } )
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion?( { throw error } )
                }
                
            }
        }
    }
    
    func fetchAsync<T: NSManagedObject>(_ classType: T.Type, by pair: (key: String, value: String), completion: ((() throws -> [T])->())? = nil) where T: ModelNameProvider  {
        let context = self.context
        //let request = FetchRequest<T>(entity: entity(name: T.modelName, context: context))
        let request = NSFetchRequest<T>(entityName: T.modelName)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [pair.key, pair.value])
        context.perform {
            completion?( { (try context.fetch(request))} )
        }
    }
    
    func fetch<T: NSManagedObject>(_ classType: T.Type, by pairs: [(key: String, value: String)], logicOperator: String) throws -> [T] where T: ModelNameProvider {
        let context = self.context
        //let request = FetchRequest<T>(entity: entity(name: T.modelName, context: context))
        let request = NSFetchRequest<T>(entityName: T.modelName)
        
        let predicateLogicOperator = " \(logicOperator) "
        
        var predicateString = pairs.dropLast().reduce("") {
            result,pair in
            return result + "\(pair.key) = \(pair.value)" + predicateLogicOperator
        }
        if let lastPair = pairs.last {
            predicateString += "\(lastPair.key) = \(lastPair.value)"
        }
        if !predicateString.isEmpty {
            request.predicate = NSPredicate(format: predicateString)
        }
        var results = [T]()
        results = try context.fetch(request)
        return results
    }
    
    func fetch<T: ModelNameProvider>(_ classType: T.Type, context: NSManagedObjectContext = LemonCoreDataManager.context) throws -> [T] where T: NSManagedObject {
        //let request = FetchRequest<T>(entity: entity(name: T.modelName, context: context))
        let request = NSFetchRequest<T>(entityName: T.modelName)
        
        var results = [T]()
        //results = try JSQCoreDataKit.fetch(request: request, inContext: context)
        results = try context.fetch(request)
        return results
    }
    
    func get<T: ModelNameProvider>(_ object:T, context: NSManagedObjectContext = LemonCoreDataManager.context) -> T? where T: NSManagedObject, T: ModelIdProvider {
        //let request = FetchRequest<T>(entity: entity(name: T.modelName, context: context))
        let request = NSFetchRequest<T>(entityName: T.modelName)
        
        request.predicate = NSPredicate(format: "\(T.idFieldName) = \(object.id)")
        var results: T?
        //results = (try? JSQCoreDataKit.fetch(request: request, inContext: context).first) ?? nil
        results = (try? context.fetch(request).first) ?? nil
        return results
    }
}

class CoreDataManager: DataFetcher {
    
    fileprivate var dataStack: CoreDataStack?
    var context: NSManagedObjectContext {
        return (dataStack?.backgroundContext)!
        
    }
    
    init(dataModel: CoreDataModel, completion: @escaping () -> ()) {
        
        let dataModel = CoreDataModel(name: "lemonapp")
        
        if dataModel.needsMigration {
            // do migration
        }
        let factory = CoreDataStackFactory(model: dataModel)
        //dataStack = factory.createStack().stack()!
        
//        factory.createStack { [weak self] stack in
//            guard let strongSelf = self else { return }
//            strongSelf.dataStack = stack.stack()!
//            completion()
//        }
//
        factory.createStack { [weak self]  (result: StackResult) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let s):
                strongSelf.dataStack = s
                break
            case .failure(let e):
                print("Error: \(e)")
                break
            }
            completion()
        }
    
    }
    
    init(dataModel: CoreDataModel) {
        if dataModel.needsMigration {
            // do migration
        }
        let factory = CoreDataStackFactory(model: dataModel)
        //dataStack = factory.createStack().stack()!
        
        factory.createStack { [weak self] stack in
            guard let strongSelf = self else { return }
            strongSelf.dataStack = stack.stack()!
        }
    }
    
    func saveChanges() {
        DispatchQueue.main.async {
            saveContext(self.context)
        }
    }
    
    func insert<T: NSManagedObject>(_ async: Bool = true, objects: T...) {
        insert(async, objects: objects)
    }
    
    func insert<T: NSManagedObject>(_ async: Bool = true, objects: [T]) {
        if async {
            context.perform {
                objects.forEach { self.context.insert($0) }
                self.saveChanges()
            }
        } else {
            context.performAndWait {
                objects.forEach { self.context.insert($0) }
                self.saveChanges()
            }
        }
    }
    
    func replace<T: ModelNameProvider>(_ async: Bool = true, objects: T...) where T: NSManagedObject {
        replace(async, objects: objects)
    }
    
    func replace<T: ModelNameProvider>(_ async: Bool = true, objects: [T]) where T: NSManagedObject {
//        print(objects.count)
        
        //if let oldObjects = try? fetch(T) {
        if let oldObjects = try? context.fetch(T.self) {
//            print(oldObjects.count)
            let objectsToDelete = oldObjects.flatMap { !objects.contains($0) ? $0 : nil }
//            print(objectsToDelete.count)
            let objectsToInsert = objects.flatMap { oldObjects.contains($0) ? nil : $0 }
//            print(objectsToInsert.count)
            delete(async, objects: objectsToDelete) {
                self.insert(async, objects: objectsToInsert)
            }
            return
        } else {
            insert(async, objects: objects)
        }
    }
    
    func delete<T: NSManagedObject>(_ async: Bool = true, objects: T...) {
        delete(async, objects: objects)
    }
    
    func delete<T: NSManagedObject>(_ async: Bool = true, objects: [T], completion:(() -> ())? = nil) {
        if async {
            context.perform {
                //JSQCoreDataKit.deleteObjects(objects, inContext: self.context)
                for each in objects {
                    self.context.delete(each)
                }
                completion?()
            }
        } else {
            context.performAndWait {
                //JSQCoreDataKit.deleteObjects(objects, inContext: self.context)
                for each in objects {
                    self.context.delete(each)
                }
                completion?()
            }
        }
    }
    
    func findWithId<T: ModelNameProvider>(_ id: Int) -> T? where T: NSManagedObject {
        //let request = FetchRequest<T>(entity: entity(name: T.modelName, context: context))
        let request = NSFetchRequest<T>(entityName: T.modelName)
        request.predicate = NSPredicate(format: "id = \(id)")
        //return (try? JSQCoreDataKit.fetch(request: request, inContext: context).first) ?? nil
        do {
            return try context.fetch(request).first
        } catch _ {
            let error = FindWithIdFailContextFetchError()
            track(error: error, additionalInfo: error.errorUserInfo)
            return nil
        }
    }
    
    func dropDataBase() {
        context.performAndWait {
            do {
                if let store = self.context.persistentStoreCoordinator?.persistentStores.last {
                    try self.context.persistentStoreCoordinator?.remove(store)
                    try self.dataStack?.model.removeExistingStore()
                    try self.context.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: store.url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    var childContext: ChildContext {
        return LemonCoreDataManager.dataStack!.childContext()
    }
}

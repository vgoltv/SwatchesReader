//
//  SRCoreDataManager.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 09.01.2021.
//

import Foundation
import CoreData

class SRCoreDataManager: ObservableObject {
    static var shared = SRCoreDataManager()
    
    /*
    _dataController.shouldMigrateStoreAutomatically = YES;
    _dataController.shouldInferMappingModelAutomatically = YES;
    _dataController.shouldAddStoreAsynchronously = NO;
    */
    
    private init() {
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        

    }
    public var context: NSManagedObjectContext {
        get {
            return self.persistentContainer.viewContext
        }
    }
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SRApp")
        container.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
        }
        return container
    }()
    
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

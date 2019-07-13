//
//  DataController.swift
//  MyVVirtualTourist
//
//  Created by Vedarth Solutions on 6/15/19.
//  Copyright © 2019 Vedarth Solutions. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer: NSPersistentContainer
    internal let savingContext: NSManagedObjectContext
    internal let backgroundContext: NSManagedObjectContext
    
    static func getInstance() -> DataController {
        struct Singleton {
            static var instance = DataController(modelName: "MyVVirtualTourist")
        }
        return Singleton.instance
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        savingContext = persistentContainer.viewContext
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func configureContexts() {
        savingContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        savingContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
}

// MARK: - Autosaving

extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        print("autosaving")
        
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        
        if savingContext.hasChanges {
            try? savingContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}


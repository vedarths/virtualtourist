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
    internal let dbURL: URL
    private let modelURL: URL
    private let model: NSManagedObjectModel
    internal let savingContext: NSManagedObjectContext
    internal let backgroundContext: NSManagedObjectContext
    internal let coordinator: NSPersistentStoreCoordinator
    static func getInstance() -> DataController {
        struct Singleton {
            static var instance = DataController(modelName: "Virtual_Tourist")!
        }
        return Singleton.instance
    }
    
    init?(modelName: String) {
        self.modelURL = getModelUrl(name: modelName, extension: "momd")!
        // create model from Url
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        persistentContainer = NSPersistentContainer(name: modelName)
        savingContext = persistentContainer.viewContext
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options : [NSObject:AnyObject]?) throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
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
    
    func getModelUrl(name: String, extension: String) -> URL? {
        guard let modelUrl = Bundle.main.url(forResource: name, withExtension: "momd") else {
            print("Unable to find \(name) in the main bundle")
            return nil
        }
        return modelUrl
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

internal extension DataController {
    func purgeData() throws {
        try coordinator.destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType, options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
}


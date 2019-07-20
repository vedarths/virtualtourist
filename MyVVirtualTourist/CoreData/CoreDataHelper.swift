//
//  CoreDataHelper.swift
//  MyVVirtualTourist
//
//  Created by Vedarth Solutions on 6/16/19.
//  Copyright © 2019 Vedarth Solutions. All rights reserved.
//

import CoreData
import MapKit

extension DataController {
    
    func fetchAllPins(_ predicate: NSPredicate? = nil, entityName: String, sorting: NSSortDescriptor? = nil) throws -> [LocationPin]? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let pin = try viewContext.fetch(fr) as? [LocationPin] else {
            return nil
        }
        return pin
    }
    
    func fetchPin(_ predicate: NSPredicate, entityName: String, sorting: NSSortDescriptor? = nil) throws -> LocationPin? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let pin = (try viewContext.fetch(fr) as! [LocationPin]).first else {
            return nil
        }
        return pin
    }
    
    func fetchPhotos(_ predicate: NSPredicate? = nil, entityName: String, sorting: NSSortDescriptor? = nil) throws -> [Photo]? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let photos = try viewContext.fetch(fr) as? [Photo] else {
            return nil
        }
        return photos
    }
    
    func saveLocationPin(_ pinAnnotation: MKPointAnnotation) {
        let locationPin = LocationPin(context: viewContext)
        locationPin.latitude = String(pinAnnotation.coordinate.latitude)
        locationPin.longitude = String(pinAnnotation.coordinate.longitude)
        do {
          try viewContext.save()
        } catch {
            print("Error while saving location pin: \(error)")
        }
    }
    
   
    
}

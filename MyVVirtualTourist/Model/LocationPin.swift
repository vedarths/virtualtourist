//
//  LocationPin.swift
//  MyVVirtualTourist
//
//  Created by Vedarth Solutions on 7/20/19.
//  Copyright © 2019 Vedarth Solutions. All rights reserved.
//

import Foundation
import CoreData

@objc(LocationPin)
public class LocationPin: NSManagedObject {
    
    static let name = "LocationPin"
    
    convenience init(latitude: String, longitude: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: LocationPin.name, in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Could not initialise entity LocationPin!")
        }
    }
    
}

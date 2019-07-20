//
//  LocationPin+Extensions.swift
//  MyVVirtualTourist
//
//  Created by Vedarth Solutions on 6/15/19.
//  Copyright © 2019 Vedarth Solutions. All rights reserved.
//

import Foundation
import CoreData

extension LocationPin {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationPin> {
        return NSFetchRequest<LocationPin>(entityName: "LocationPin")
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
    }
    
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var photos: NSSet?
}

extension LocationPin {
    
    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)
    
    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)
    
    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)
    
    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)
    
}

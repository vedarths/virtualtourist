//
//  Photos+Extension.swift
//  MyVVirtualTourist
//
//  Created by Vedarth Solutions on 6/15/19.
//  Copyright © 2019 Vedarth Solutions. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
    }
    
    @NSManaged public var image: NSData?
    @NSManaged public var title: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var pin: LocationPin?
}


//
//  FlickerConstants.swift
//  MyVVirtualTourist
//
//  Created by Vedarth Solutions on 7/13/19.
//  Copyright © 2019 Vedarth Solutions. All rights reserved.
//

import Foundation

extension FlickerClient {
    
    struct Constants {
        
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
        
        static let SearchBBoxHalfWidth = 0.2
        static let SearchBBoxHalfHeight = 0.2
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let BoundingBox = "bbox"
        static let PhotosPerPage = "per_page"
        static let Accuracy = "accuracy"
        static let Page = "page"
    }
    
    // MARK: - Flickr Parameter Values
    
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "73b2b0363ffb9110ebce27808e448e32"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let MediumURL = "url_n"
        static let UseSafeSearch = "1" /* 1 means safe content */
        static let PhotosPerPage = 30
        static let AccuracyCityLevel = "11"
        static let AccuracyStreetLevel = "16"
    }
    
}

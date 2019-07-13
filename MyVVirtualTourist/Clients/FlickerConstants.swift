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
        
        static let AcceptKey = "Accept"
        static let ContentType = "Content-Type"
        static let ApplicationId = "X-Parse-Application-Id"
        static let ApiKey = "X-Parse-REST-API-Key"
        
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
        static let APIKey = "e642c34c6ac8532ef77a7ec1c221babc"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let MediumURL = "url_n"
        static let UseSafeSearch = "1" /* 1 means safe content */
        static let PhotosPerPage = 30
        static let AccuracyCityLevel = "11"
        static let AccuracyStreetLevel = "16"
    }
    
    
    struct HeaderValues {
        static let ApplicationIdValue = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApiKeyValue = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    struct Methods {
        static let Location = "/StudentLocation"
    }
    
    struct URLArgumentKeys {
        static let Limit = "limit"
        static let Skip = "skip"
        static let Where = "where"
    }
    
    struct URLArgumentValues {
        static let limit = "40"
        static let Skip = "400"
    }
    
    
}

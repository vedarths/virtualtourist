//
//  FlickrClientOperations.swift
//  MyVVirtualTourist
//
//  Created by Vedarth Solutions on 7/13/19.
//  Copyright © 2019 Vedarth Solutions. All rights reserved.
//

import Foundation

extension FlickerClient {
    
    func findBy(latitude: Double, longitude: Double, totalPages: Int?, completion: @escaping (_ result: PhotosJsonParser?, _ error: Error?) -> Void) {
        
        //get any random page
        var page: Int {
            if let totalPages = totalPages {
                let page = min(totalPages, 100/FlickrParameterValues.PhotosPerPage)
                return Int(arc4random_uniform(UInt32(page)) + 1)
            }
            return 1
        }
        let bbox = bboxString(latitude: latitude, longitude: longitude)
        
        let parameters = [
            FlickrParameterKeys.Method           : FlickrParameterValues.SearchMethod
            , FlickrParameterKeys.APIKey         : FlickrParameterValues.APIKey
            , FlickrParameterKeys.Format         : FlickrParameterValues.ResponseFormat
            , FlickrParameterKeys.Extras         : FlickrParameterValues.MediumURL
            , FlickrParameterKeys.NoJSONCallback : FlickrParameterValues.DisableJSONCallback
            , FlickrParameterKeys.SafeSearch     : FlickrParameterValues.UseSafeSearch
            , FlickrParameterKeys.BoundingBox    : bbox
            , FlickrParameterKeys.PhotosPerPage  : "\(FlickrParameterValues.PhotosPerPage)"
            , FlickrParameterKeys.Page           : "\(page)"
        ]
        
        _ = taskForGETMethod(parameters: parameters as [String : AnyObject]) { (data, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey: "Data retrieval failed"]
                completion(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                return
            }
            do {
                let photosParser = try JSONDecoder().decode(PhotosJsonParser.self, from: data )
                completion(photosParser, nil)
            } catch {
                print("\(#function) error: \(error)")
                completion(nil, error)
            }
        }
    }
    
    func getImage(imageUrl: String, result: @escaping (_ result: Data?, _ error: NSError?) -> Void) {
        guard let url = URL(string: imageUrl) else {
            return
        }
        
        let task = taskForGETMethod(nil, url, parameters: [:]) { (data, error) in
            result(data, error)
            self.tasks.removeValue(forKey: imageUrl)
        }
        
        if tasks[imageUrl] == nil {
            tasks[imageUrl] = task
        }
    }
    
    func cancelDownload(_ imageUrl: String) {
        tasks[imageUrl]?.cancel()
        if tasks.removeValue(forKey: imageUrl) != nil {
            print("\(#function) task canceled: \(imageUrl)")
        }
    }
}

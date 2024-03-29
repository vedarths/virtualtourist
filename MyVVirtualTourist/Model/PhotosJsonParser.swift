//
//  PhotosParser.swift
//  MyVVirtualTourist
//
//  Created by Vedarth Solutions on 7/13/19.
//  Copyright © 2019 Vedarth Solutions. All rights reserved.
//

import Foundation

struct PhotosJsonParser: Codable {
    let photos: Photos
}

struct Photos: Codable {
    let pages: Int
    let photo: [PhotoJsonParser]
}

struct PhotoJsonParser: Codable {
    
    let url: String?
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url_n"
        case title
    }
}

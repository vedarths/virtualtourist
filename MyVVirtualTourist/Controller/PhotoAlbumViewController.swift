//
//  PhotoAlbumViewController.swift
//  MyVVirtualTourist
//
//  Created by Vedarth Solutions on 6/16/19.
//  Copyright © 2019 Vedarth Solutions. All rights reserved.
//

import Foundation

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
    }
    
}

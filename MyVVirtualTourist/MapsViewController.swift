//
//  ViewController.swift
//  MyVVirtualTourist
//
//  Created by Vedarth Solutions on 6/8/19.
//  Copyright © 2019 Vedarth Solutions. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapsViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapKit: MKMapView!
    var pinAnnotation: MKPointAnnotation? = nil
    
    var dataController:DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapKit.delegate = self
    }

    @IBAction func handleLongPressAction(_ sender: UILongPressGestureRecognizer) {
       addAnnotation(gestureRecognizer: sender)
    }
    
    func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapKit)
        let newCoordinates = mapKit.convert(touchPoint, toCoordinateFrom: mapKit)
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            pinAnnotation = MKPointAnnotation()
            pinAnnotation!.coordinate = newCoordinates
            
            print("\(#function) Coordinate: \(newCoordinates.latitude),\(newCoordinates.longitude)")
            
            mapKit.addAnnotation(pinAnnotation!)
        } else if gestureRecognizer.state == .changed {
            pinAnnotation!.coordinate = newCoordinates
        } else if gestureRecognizer.state == .ended {
            let locationPin = LocationPin(context: dataController.viewContext)
            locationPin.latitude = String(pinAnnotation!.coordinate.latitude)
            locationPin.longitude = String(pinAnnotation!.coordinate.longitude)
            try? dataController.viewContext.save()
        }
    }
   
}



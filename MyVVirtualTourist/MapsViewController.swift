//
//  ViewController.swift
//  MyVVirtualTourist
//
//  Created by Vedarth Solutions on 6/8/19.
//  Copyright © 2019 Vedarth Solutions. All rights reserved.
//

import UIKit
import MapKit

class MapsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapKit: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let uiLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MKMapView.addAnnotation(_:)))
        uiLongPressGestureRecognizer.minimumPressDuration = 2.0
        mapKit.addGestureRecognizer(uiLongPressGestureRecognizer)
        
    }

    func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = gestureRecognizer.location(in: mapKit)
            let newCoordinates = mapKit.convert(touchPoint, toCoordinateFrom: mapKit)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geo coding failed with error" + (error?.localizedDescription)!)
                    return
                }
                if (placemarks?.count)! > 0 {
                    let placemark = placemarks![0] as CLPlacemark
                    annotation.title = placemark.thoroughfare! + ", " + placemark.subThoroughfare!
                    annotation.subtitle = placemark.subLocality
                    self.mapKit.addAnnotation(annotation)
                    print(placemark)
                } else {
                    annotation.title = "Unknown Place"
                    self.mapKit.addAnnotation(annotation)
                    print("Problem with the data recieved from the geo coder")
                }
               // places.append(["name":annotation.title, "latitude":"\(newCoordinates.latitude)", "longitude":"\(newCoordinates.longitude)"])
            })
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil}
        let identifier = "Annotation"
        var annotationView = mapKit.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
           annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
           annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
}



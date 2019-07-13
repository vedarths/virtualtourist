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
    
    @IBOutlet weak var footer: UIView!
    @IBOutlet weak var mapView: MKMapView!
    var dataController:DataController!
    var pinAnnotation: MKPointAnnotation? = nil
    var fetchedResultsController:NSFetchedResultsController<LocationPin>!
    
    @IBOutlet var gestureRecognizers: [UILongPressGestureRecognizer]!
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<LocationPin> = LocationPin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "locationPins")
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        navigationItem.rightBarButtonItem = editButtonItem
        setupFetchedResultsController()
        footer.isHidden = true
        if let locationPins = getAllPins() {
            showPins(locationPins)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        footer.isHidden = !editing
    }
    
    private func getAllPins() -> [LocationPin]? {
        var pins: [LocationPin]?
        do {
            try pins = DataController.getInstance().fetchAllPins(entityName: "LocationPin")
        } catch {
            print("\(#function) error:\(error)")
            //showInfo(withTitle: "Error", withMessage: "Error while fetching locations: \(error)")
        }
        return pins
    }
    
    func showPins(_ pins: [LocationPin]) {
        for pin in pins where pin.latitude != nil && pin.longitude != nil {
            let annotation = MKPointAnnotation()
            let lat = Double(pin.latitude!)!
            let lon = Double(pin.longitude!)!
            annotation.coordinate = CLLocationCoordinate2DMake(lat, lon)
            mapView.addAnnotation(annotation)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }

  
    @IBAction func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        addAnnotation(gestureRecognizer: sender)
    }
    func addAnnotation(gestureRecognizer: UILongPressGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            pinAnnotation = MKPointAnnotation()
            pinAnnotation!.coordinate = newCoordinates
            
            print("\(#function) Coordinate: \(newCoordinates.latitude),\(newCoordinates.longitude)")
            
            mapView.addAnnotation(pinAnnotation!)
        } else if gestureRecognizer.state == .changed {
            pinAnnotation!.coordinate = newCoordinates
        } else if gestureRecognizer.state == .ended {
            dataController.saveLocationPin(pinAnnotation!)
        }
    }
   
    private func getPin(latitude: String, longitude: String) -> LocationPin? {
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", latitude, longitude)
        var pin: LocationPin?
        do {
            try pin = DataController.getInstance().fetchPin(predicate, entityName: "LocationPin")
        } catch {
            print("\(#function) error:\(error)")
            //showInfo(withTitle: "Error", withMessage: "Error while fetching location: \(error)")
        }
        return pin
    }
    
}



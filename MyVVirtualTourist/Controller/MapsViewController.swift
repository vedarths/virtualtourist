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
    @IBOutlet weak var footerView: UIView!
    
    var pinAnnotation: MKPointAnnotation? = nil
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<LocationPin>!
    
    fileprivate func setupFetchedResultsController() {
//        let fetchRequest:NSFetchRequest<LocationPin> = LocationPin.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.savingContext, sectionNameKeyPath: nil, cacheName: "locationPins")
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            fatalError("The fetch could not be performed: \(error.localizedDescription)")
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapKit.delegate = self
        setupFetchedResultsController()
        footerView.isHidden = true
        if let locationPins = getAllPins() {
            getPins(locationPins)
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
            dataController.saveLocationPin(pinAnnotation!)
        }
    }
   
    private func getAllPins() -> [LocationPin]? {
        var pins: [LocationPin]?
        do {
            try locationPins = CoreDataHelper.getInstance().fetchAllPins(entityName: LocationPin.name)
        } catch {
            print("\(#function) error:\(error)")
            showInfo(withTitle: "Error", withMessage: "Error while fetching Pin locations: \(error)")
        }
        return pins
    }
    
}



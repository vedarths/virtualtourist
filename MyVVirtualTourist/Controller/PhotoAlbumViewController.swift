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
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    
    var selected = [IndexPath]()
    var created: [IndexPath]!
    var deleted: [IndexPath]!
    var updated: [IndexPath]!
    var totalPages: Int? = nil
    
    var alert = false
    var locationPin: LocationPin?
    var fetchedResultController: NSFetchedResultsController<Photo>
    var dataController:DataController!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "photos")
        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var labelStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFlowLayout(view.frame.size)
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        updateStatusLabel("")
        
        guard let pin = locationPin else {
            return
        }
        showOnTheMap(pin)
        setupFetchedResultControllerWith(pin)
        
        if let photos = pin.photos, photos.count == 0 {
            // pin selected has no photos - get from Flickr
            getPhotosFromFlickr(pin)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateFlowLayout(size)
    }
    
    private func updateFlowLayout(_ withSize: CGSize) {
        
        let landscape = withSize.width > withSize.height
        
        let space: CGFloat = landscape ? 5 : 3
        let items: CGFloat = landscape ? 2 : 3
        
        let dimension = (withSize.width - ((items + 1) * space)) / items
        
        flowLayout?.minimumInteritemSpacing = space
        flowLayout?.minimumLineSpacing = space
        flowLayout?.itemSize = CGSize(width: dimension, height: dimension)
        flowLayout?.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
    }
    
    private func setupFetchedResultControllerWith(_ pin: LocationPin) {
        
        let fr = NSFetchRequest<Photo>(entityName: Photo.name)
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: DataController.shared().context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        
        var error: NSError?
        do {
            try fetchedResultController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("\(#function) Error performing initial fetch: \(error)")
        }
    }
    
    private func getPhotosFromFlickr(_ pin: LocationPin) {
        
        let lat = Double(pin.latitude!)!
        let lon = Double(pin.longitude!)!
        
        activityIndicator.startAnimating()
        self.updateStatusLabel("Fetching photos ...")
        
        FlickerClient.sharedInstance().findBy(latitude: lat, longitude: lon, totalPages: totalPages) { (photosParsed, error) in
            self.performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
                self.labelStatus.text = ""
            }
            if let photosParsed = photosParsed {
                self.totalPages = photosParsed.photos.pages
                let totalPhotos = photosParsed.photos.photo.count
                print("\(#function) Downloading \(totalPhotos) photos.")
                self.storePhotos(photosParsed.photos.photo, forPin: pin)
                if totalPhotos == 0 {
                    self.updateStatusLabel("No photos found for this location 😢")
                }
            } else if let error = error {
                print("\(#function) error:\(error)")
                self.showInfo(withTitle: "Error", withMessage: error.localizedDescription)
                self.updateStatusLabel("Something went wrong, please try again 🧐")
            }
        }
    }
    
    private func updateStatusLabel(_ text: String) {
        self.performUIUpdatesOnMain {
            self.labelStatus.text = text
        }
    }
    
    private func storePhotos(_ photos: [PhotoParser], forPin: LocationPin) {
        func showErrorMessage(msg: String) {
            showInfo(withTitle: "Error", withMessage: msg)
        }
        
        for photo in photos {
            performUIUpdatesOnMain {
                if let url = photo.url {
                    _ = Photo(context: dataController.viewContext)
                    try? dataController.viewContext.save()
                }
            }
        }
    }
    
    private func showOnTheMap(_ pin: LocationPin) {
        
        let lat = Double(pin.latitude!)!
        let lon = Double(pin.longitude!)!
        let locCoord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        mapView.setCenter(locCoord, animated: true)
    }
    
    private func loadPhotos(using pin: LocationPin) -> [Photo]? {
        let predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        var photos: [Photo]?
        do {
            try photos = dataController.fetchPhotos(predicate, entityName: "Photo")
        } catch {
            print("\(#function) error:\(error)")
            showInfo(withTitle: "Error", withMessage: "Error while lading Photos from disk: \(error)")
        }
        return photos
    }
    
    
    func updateBottomButton() {
        if selectedIndexes.count > 0 {
            button.setTitle("Remove Selected", for: .normal)
        } else {
            button.setTitle("New Collection", for: .normal)
        }
    }
}


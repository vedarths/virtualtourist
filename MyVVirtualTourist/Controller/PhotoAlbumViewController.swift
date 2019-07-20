//
//  PhotoAlbumViewController.swift
//  MyVVirtualTourist
//
//  Created by Vedarth Solutions on 6/16/19.
//  Copyright © 2019 Vedarth Solutions. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout?
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelStatus: UILabel!
    
    // MARK: - Variables
    
    var selected = [IndexPath]()
    var inserted: [IndexPath]!
    var deleted: [IndexPath]!
    var updated: [IndexPath]!
    var totalPages: Int? = nil
    
    var presentingAlert = false
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var locationPin : LocationPin?
    var latitude: String?
    var longitude: String?
    
    // MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFlowLayout(view.frame.size)
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        // we're setting an empty text in it.
        setStatusLabel("")
        let pin = getPin(latitude: latitude!, longitude: longitude!)
        showOnTheMap(pin!)
        setupFetchedResultControllerWith(pin!)
        if let photos = pin!.photos, photos.count == 0 {
            // pin selected has no photos
            fetchPhotosFromAPI(pin!)
        }
        self.locationPin = pin!
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateFlowLayout(size)
    }
    
    // MARK: - Actions
    
    @IBAction func deleteAction(_ sender: Any) {
        // delete all photos
        for photos in fetchedResultsController.fetchedObjects! {
            DataController.getInstance().viewContext.delete(photos)
        }
        save()
        fetchPhotosFromAPI(locationPin!)
    }
    
    // MARK: - Helpers
    
    private func setupFetchedResultControllerWith(_ pin: LocationPin) {
        
        let fr = NSFetchRequest<Photo>(entityName: Photo.name)
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: DataController.getInstance().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        // Start the fetched results controller
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("\(#function) Error performing initial fetch: \(error)")
        }
    }
    
    private func fetchPhotosFromAPI(_ pin: LocationPin) {
        
        let lat = Double(pin.latitude!)!
        let lon = Double(pin.longitude!)!
        
        activityIndicator.startAnimating()
        self.setStatusLabel("Retrieving photos ...")
        
        FlickerClient.sharedInstance().findBy(latitude: lat, longitude: lon, totalPages: totalPages) { (photosParsed, error) in
            self.performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
                self.labelStatus.text = ""
            }
            if let photosParsed = photosParsed {
                self.totalPages = photosParsed.photos.pages
                let totalPhotos = photosParsed.photos.photo.count
                self.storePhotos(photosParsed.photos.photo, forPin: pin)
                if totalPhotos == 0 {
                    self.setStatusLabel("No photos found for this location 😢")
                }
            } else if let error = error {
                print("\(#function) error:\(error)")
                self.showInfo(withTitle: "Error", withMessage: error.localizedDescription)
                self.setStatusLabel("Something went wrong, please try again 🧐")
            }
        }
    }
    
    private func setStatusLabel(_ text: String) {
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
                    _ = Photo(title: photo.title, imageUrl: url, forPin: forPin, context: DataController.getInstance().viewContext)
                    self.save()
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
            try photos = DataController.getInstance().fetchPhotos(predicate, entityName: Photo.name)
        } catch {
            print("\(#function) error:\(error)")
            showInfo(withTitle: "Error", withMessage: "Error while lading Photos from disk: \(error)")
        }
        return photos
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
    
    func updateBottomButton() {
        if selected.count > 0 {
            button.setTitle("Remove Selected", for: .normal)
        } else {
            button.setTitle("New Collection", for: .normal)
        }
    }
}

// MARK: - MKMapViewDelegate

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
        cell.imageView.image = nil
        cell.activityIndicator.startAnimating()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionInfo = self.fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = self.fetchedResultsController.object(at: indexPath)
        let photoCell = cell as! PhotoCell
        photoCell.imageUrl = photo.imageUrl!
        configImage(using: photoCell, photo: photo, collectionView: collectionView, index: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        DataController.getInstance().viewContext.delete(photoToDelete)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying: UICollectionViewCell, forItemAt: IndexPath) {
        
        if collectionView.cellForItem(at: forItemAt) == nil {
            return
        }
        
        let photo = fetchedResultsController.object(at: forItemAt)
        if let imageUrl = photo.imageUrl {
            FlickerClient.sharedInstance().cancelDownload(imageUrl)
        }
    }
    
    private func configImage(using cell: PhotoCell, photo: Photo, collectionView: UICollectionView, index: IndexPath) {
        if let imageData = photo.image {
            cell.activityIndicator.stopAnimating()
            cell.imageView.image = UIImage(data: Data(referencing: imageData))
        } else {
            if let imageUrl = photo.imageUrl {
                cell.activityIndicator.startAnimating()
                FlickerClient.sharedInstance().getImage(imageUrl: imageUrl) { (data, error) in
                    if let _ = error {
                        self.performUIUpdatesOnMain {
                            cell.activityIndicator.stopAnimating()
                            self.errorForImageUrl(imageUrl)
                        }
                        return
                    } else if let data = data {
                        self.performUIUpdatesOnMain {
                            
                            if let currentCell = collectionView.cellForItem(at: index) as? PhotoCell {
                                if currentCell.imageUrl == imageUrl {
                                    currentCell.imageView.image = UIImage(data: data)
                                    cell.activityIndicator.stopAnimating()
                                }
                            }
                            photo.image = NSData(data: data)
                            DispatchQueue.global(qos: .background).async {
                                self.save()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func errorForImageUrl(_ imageUrl: String) {
        if !self.presentingAlert {
            self.showInfo(withTitle: "Error", withMessage: "Error while fetching image for URL: \(imageUrl)", action: {
                self.presentingAlert = false
            })
        }
        self.presentingAlert = true
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        inserted = [IndexPath]()
        deleted = [IndexPath]()
        updated = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            inserted.append(newIndexPath!)
            break
        case .delete:
            deleted.append(indexPath!)
            break
        case .update:
            updated.append(indexPath!)
            break
        case .move:
            print("Move item.")
            break
        @unknown default:
            print("Default behaviour.")
            break
        }
    }
    // Handle controller behaviours for insertion, deletion and updates
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.inserted {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deleted {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updated {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
}

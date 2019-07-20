//
//  PhotoAlbumViewController+Extension.swift
//  MyVVirtualTourist
//
//  Created by Vedarth Solutions on 7/20/19.
//  Copyright © 2019 Vedarth Solutions. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        created = [IndexPath]()
        deleted = [IndexPath]()
        updated = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            created.append(newIndexPath!)
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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.created {
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

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
        cell.imageView.image = nil
        cell.activityIndicator.startAnimating()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionInfo = self.fetchedResultController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = fetchedResultController.object(at: indexPath)
        let photoViewCell = cell as! PhotoCell
        photoViewCell.imageUrl = photo.imageUrl!
        configImage(using: photoViewCell, photo: photo, collectionView: collectionView, index: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying: UICollectionViewCell, forItemAt: IndexPath) {
        
        if collectionView.cellForItem(at: forItemAt) == nil {
            return
        }
        
        let photo = fetchedResultController.object(at: forItemAt)
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
        if !self.alert {
            self.showInfo(withTitle: "Error", withMessage: "Error while fetching image for URL: \(imageUrl)", action: {
                self.alert = false
            })
        }
        self.alert = true
    }
}

//
//  PhotoAlbumViewController+Extension.swift
//  MyVVirtualTourist
//
//  Created by Vedarth Solutions on 7/20/19.
//  Copyright © 2019 Vedarth Solutions. All rights reserved.
//

import Foundation
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

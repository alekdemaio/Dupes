//
//  ViewController.swift
//  Dupes
//
//  Created by Alek DeMaio on 3/25/25.
//

import UIKit
import PhotosUI
//import PHPhotoLibrary //look into this, probably method to remove pics

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    var assetsToDelete: [PHAsset] = []
    
    // Request authorization to modify the photo library
    func requestPhotoLibraryAuthorization() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    print("Photo library access granted")
                default:
                    print("Photo library access blocked")
                    //implement popup
                }
            }
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // Collect assets to delete
        //assetsToDelete moved line ^^
        for result in results {
            print(result.assetIdentifier ?? "no value")
            if let assetIdentifier = result.assetIdentifier {
                let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
                assetsToDelete.append(fetchResult.object(at: 0))
            }
        }
        deletePhotos(withAssetIdentifiers: assetsToDelete)
        print(assetsToDelete)
        print(results)
        picker.dismiss(animated: true)
    }
    
    func deletePhotos(withAssetIdentifiers assets: [PHAsset]) {
        let assetIdentifiers = assets.map { $0.localIdentifier } // Extract localIdentifiers

        PHPhotoLibrary.shared().performChanges({
            // Fetch assets using the extracted identifiers
            let fetchedAssets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)

            // Convert PHFetchResult<PHAsset> to an array
            let assetsArray = (0..<fetchedAssets.count).map { fetchedAssets.object(at: $0) }

            // Delete the assets
            PHAssetChangeRequest.deleteAssets(assetsArray as NSFastEnumeration)

        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("Photos deleted successfully!")
                } else {
                    print("Error deleting photos: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    // Prepare data before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSwipeController",
           let destinationVC = segue.destination as? SwipeController {
            destinationVC.assetsToDelete = assetsToDelete
        }
    }
    @IBAction func openGalleryBtn(_ sender: Any) {
        requestPhotoLibraryAuthorization()
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 0 // 0 = unlimited, set to any number you want
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
        performSegue(withIdentifier: "toSwipeController", sender: self)
    }
}


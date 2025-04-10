//
//  ViewController.swift
//  Dupes
//
//  Created by Alek DeMaio on 3/25/25.
//

import UIKit
import PhotosUI

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
                }
            }
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // Collect assets to delete
        assetsToDelete = []
        for result in results {
            print(result.assetIdentifier ?? "no value")
            if let assetIdentifier = result.assetIdentifier {
                let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
                assetsToDelete.append(fetchResult.object(at: 0))
            }
        }
        print(assetsToDelete)
        print(results)
        picker.dismiss(animated: true)
        if !self.assetsToDelete.isEmpty {
            self.performSegue(withIdentifier: "toSwipeController", sender: self)
        } else {
            print("No assets selected")
        }
    }
    
    // Prepare data before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSwipeController",
           let destinationVC = segue.destination as? SwipeController {
            print(!assetsToDelete.isEmpty)
            destinationVC.assetsToDelete = self.assetsToDelete
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
    }
}

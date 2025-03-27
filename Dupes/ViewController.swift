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

    var imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        addImageView()
    }
    
    // Request authorization to modify the photo library
    func requestPhotoLibraryAuthorization() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized, .limited:
                print("Photo library access granted")
            default:
                print("Photo library access denied")
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            imageView.image = image
        } else if let image = info[.originalImage] as? UIImage {
            imageView.image = image
        }
        
        dismiss(animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // Collect assets to delete
        var assetsToDelete: [PHAsset] = []
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

    @IBAction func openGalleryBtn(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    @IBAction func _openGalleryBtn(_ sender: Any) {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 0 // 0 = unlimited, set to any number you want
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func addImageView() {
        imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        view.addSubview (imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            imageView.centerXAnchor.constraint (equalTo: view.centerXAnchor, constant: 0),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.widthAnchor.constraint (equalTo: imageView.heightAnchor, multiplier: 1),
        ])
    }
}


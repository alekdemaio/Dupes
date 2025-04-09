//
//  SwipeController.swift
//  Dupes
//
//  Created by Alek DeMaio on 4/2/25.
//

import UIKit
import PhotosUI

class SwipeController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var assetsToDelete: [PHAsset] = []
    var deleteList: [PHAsset] = []
    var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true
        print(assetsToDelete)
        // Do any additional setup after loading the view.
        // Create an instance of PHImageRequestOptions
        // Add pinch gesture
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        imageView.addGestureRecognizer(pinchGesture)
        getNextImage()
        
    }
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .began || gesture.state == .changed {
            imageView.transform = imageView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1.0 // Reset scale
        }
        else if gesture.state == .ended || gesture.state == .cancelled {
            // Return to original position and scale when the gesture ends
            UIView.animate(withDuration: 0.3) {
                self.imageView.transform = .identity // Resets to original transform
                self.imageView.center = self.view.center // Centers the image
            }
        }
    }
    
    func getNextImage() {
        print("Image Number \(index)")
        print(assetsToDelete.count)
        let options = PHImageRequestOptions()
        options.isSynchronous = false         // Perform asynchronously (do not block the main thread)
        options.isNetworkAccessAllowed = true // Allow fetching from iCloud if image is not available locally
        options.deliveryMode = .highQualityFormat // Request high-quality format
        if index >= assetsToDelete.count {
            print("No more images")
            print(deleteList)
            // POTENTIALLY RETURN TO MAIN MENU HERE AND PERFORM DELETIONS ON LIST | DELETE LIST
            deletePhotos(withAssetIdentifiers: deleteList)
            return
        }
        PHImageManager.default().requestImage(for: assetsToDelete[index], targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options, resultHandler: { image, info in
                if let image = image {
                    // Image was successfully retrieved
                    // Do something with the image (e.g., display it in an UIImageView)
                    DispatchQueue.main.async {
                        // Example: Set the image to an image view
                        self.imageView.image = image
                    }
                } else {
                    // Handle the error or case where the image is nil
                    print("Failed to retrieve image.")
                }
            }
        )
    }
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        print("Pan gesture recognized!")
        let card = sender.view!
        let point = sender.translation(in: view)
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        if sender.state == UIGestureRecognizer.State.ended {
            
            if card.center.x < 75 {
                // move off left and add to list to delete
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 75)
                    card.alpha = 0
                })
                // list of actual delete values after all cards are panned through -- NOT TESTED
                deleteList.append(assetsToDelete[index])
                index += 1 // increment index
                getNextImage()
                resetCard(card)
                return
            } else if card.center.x > view.frame.width - 75 {
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                    card.alpha = 0
                })
                index += 1
                getNextImage()
                resetCard(card)
                return
            }
            resetCard(card)
        }
    }
    
    func resetCard(_ card: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            card.center = self.view.center
            if self.index >= self.assetsToDelete.count {
                //sets card to transparent when at the end
                card.alpha = 0
            }
            else {
                card.alpha = 1
            }
        })
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

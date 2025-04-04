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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true
        print(assetsToDelete)
        // Do any additional setup after loading the view.
        // Create an instance of PHImageRequestOptions
        let options = PHImageRequestOptions()
        options.isSynchronous = false         // Perform asynchronously (do not block the main thread)
        options.isNetworkAccessAllowed = true // Allow fetching from iCloud if image is not available locally
        options.deliveryMode = .highQualityFormat // Request high-quality format
        PHImageManager.default().requestImage(for: assetsToDelete[0], targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options, resultHandler: { image, info in
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
            UIView.animate(withDuration: 0.4, animations: {
                card.center = self.view.center
            })
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

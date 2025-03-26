//
//  ViewController.swift
//  Dupes
//
//  Created by Alek DeMaio on 3/25/25.
//

import UIKit
import PhotosUI

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {

    var imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        addImageView()
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
        print(results)
        picker.dismiss(animated: true)
    }
    
    @IBAction func openGalleryBtn(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    @IBAction func _openGalleryBtn(_ sender: Any) {
        var configuration = PHPickerConfiguration()
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


//
//  TaskDetailViewController.swift
//  lab-task-squirrel
//
//  Created by Charlie Hieger on 11/15/22.
//

import UIKit
import MapKit

// TODO: Import PhotosUI
import PhotosUI

class TaskDetailViewController: UIViewController {

    @IBOutlet private weak var completedImageView: UIImageView!
    @IBOutlet private weak var completedLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var attachPhotoButton: UIButton!

    // MapView outlet
    @IBOutlet private weak var mapView: MKMapView!

    var task: Task!

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Register custom annotation view

        // TODO: Set mapView delegate

        // UI Candy
        mapView.layer.cornerRadius = 12


        updateUI()
        updateMapView()
    }

    /// Configure UI for the given task
    private func updateUI() {
        titleLabel.text = task.title
        descriptionLabel.text = task.description

        let completedImage = UIImage(systemName: task.isComplete ? "circle.inset.filled" : "circle")

        // calling `withRenderingMode(.alwaysTemplate)` on an image allows for coloring the image via it's `tintColor` property.
        completedImageView.image = completedImage?.withRenderingMode(.alwaysTemplate)
        completedLabel.text = task.isComplete ? "Complete" : "Incomplete"

        let color: UIColor = task.isComplete ? .systemBlue : .tertiaryLabel
        completedImageView.tintColor = color
        completedLabel.textColor = color

        mapView.isHidden = !task.isComplete
        attachPhotoButton.isHidden = task.isComplete
    }

    @IBAction func didTapAttachPhotoButton(_ sender: Any) {
        // TODO: Check and/or request photo library access authorization.
        
        // check authorization status
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
            
            // request photo library access
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                
                switch status {
                case .authorized:
                    // The user authorized access to their photo library
                    // show picker (on main thread)
                    DispatchQueue.main.async {
                        self?.presentImagePicker()
                    }
                    
                default:
                    // show settings alert on main thread
                    DispatchQueue.main.async {
                        // helper method to show settings alert
                        self?.presentGoToSettingsAlert()
                    }
                }
                
            }
        } else {
            // show image picker
            presentImagePicker()
        }
          

    }

    private func presentImagePicker() {
        // TODO: Create, configure and present image picker.
        
        // create a configuration object
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        
        // set filter to only show imagaes as options (i.e. no videos)
        config.filter = .images
        
        // request the original file format. Fastest method because it avoids transcoding
        config.preferredAssetRepresentationMode = .current
        
        // only allow 1 image to be selected at a time
        config.selectionLimit = 1
        
        // instantiate a picker, passing in the configuration
        let picker = PHPickerViewController(configuration: config)
        
        // set the picker delegate so I can receive whatever image the user picks
        picker.delegate = self
        
        // present the picker
        present(picker, animated: true)
    }

    func updateMapView() {
        // TODO: Set map viewing region and scale

        // TODO: Add annotation to map view
    }
}

// TODO: Conform to PHPickerViewControllerDelegate + implement required method(s)

// TODO: Conform to MKMapKitDelegate + implement mapView(_:viewFor:) delegate method.

// Helper methods to present various alerts
extension TaskDetailViewController {

    /// Presents an alert notifying user of photo library access requirement with an option to go to Settings in order to update status.
    func presentGoToSettingsAlert() {
        let alertController = UIAlertController (
            title: "Photo Access Required",
            message: "In order to post a photo to complete a task, we need access to your photo library. You can allow access in Settings",
            preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }

        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    /// Show an alert for the given error
    private func showAlert(for error: Error? = nil) {
        let alertController = UIAlertController(
            title: "Oops...",
            message: "\(error?.localizedDescription ?? "Please try again...")",
            preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)

        present(alertController, animated: true)
    }
    
    
    // MARK: - View Controller extension for PHPicker
    
    extension TaskDetailViewController: PHPickerViewControllerDelegate {
        
    }
}

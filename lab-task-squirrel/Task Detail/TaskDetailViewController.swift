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

    // button to view photo
    @IBOutlet weak var viewPhotoButton: UIButton!
    
    // MapView outlet
    @IBOutlet private weak var mapView: MKMapView!

    var task: Task!

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Register custom annotation view
        mapView.register(TaskAnnotationView.self, forAnnotationViewWithReuseIdentifier: TaskAnnotationView.identifier)
        // TODO: Set mapView delegate
        mapView.delegate = self
        // UI Candy
        mapView.layer.cornerRadius = 12


        updateUI()
        updateMapView()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Segue to Detail View Controller
        if segue.identifier == "PhotoSegue" {
            if let photoViewController = segue.destination as? PhotoViewController {
                photoViewController.task = task
            }
        }
            
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
        viewPhotoButton.isHidden = !task.isComplete

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
        // make sure the task has image location
        
        guard let imageLocation = task.imageLocation else {return }
        
        // TODO: Add annotation to map view
        // get the coordinate from the image location . This is the latitude / longitude of the location
        let coordinate = imageLocation.coordinate
        
        // set the map view's region based on the coordinate of the image
        // the span represents the the maps's "zoom level".
        // A smaller value yields a more "zoomed in" map area, while a larger value is more "zoomed out".
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        
        // Add an annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
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
    
    
    
}

// MARK: - View Controller extension for PHPicker

extension TaskDetailViewController: PHPickerViewControllerDelegate {
    
    // function to get metadata from the photo
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        // dismiss the picker
        picker.dismiss(animated: true)
        
        // get the selected image asset -- grab the 1st item in the array since only allowed a selection limit of 1
        let result = results.first
        
        // get image location
        // PHAsset contains metadata about an image or video (ex. location, size, etc.)
        
        guard let assetId = result?.assetIdentifier,
              let location = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject?.location else {
            print("No location data in selected image")
            return
        }
        
        print("📍 Image location coordinate: \(location.coordinate)")
        
        
        // Get the chosen image
        
        // make sure there is a non-nil item provider
        guard let provider = result?.itemProvider,
              // make sure the provider can load a UIImage
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        // Load a UIImage from the provider
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            
            // handle any errors
            if let error = error {
                DispatchQueue.main.async { [weak self] in self?.showAlert(for: error) }
                
                
            }
            
            // make sure I can cast the returned object to a UIImage
            guard let image = object as? UIImage else { return }
            
            print("🌉 We have an image!")
            
            // UI updates should be done on the main thread
            DispatchQueue.main.async { [weak self] in
                
                // set the picked image and location on the task
                self?.task.set(image, with: location)
                
                // update the UI since I updated the task
                self?.updateUI()
                
                // update the map view since I now have an image location
                self?.updateMapView()
            }
            
            
        }
        
    }
    
}

// MARK: - MKMAPView Extension

extension TaskDetailViewController: MKMapViewDelegate {
    
    // Implement mapView(_:viewFor:) delegate method.
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        // Dequeue the annotation view for the specified reuse identifier and annotation.
        // Cast the dequeued annotation view to your specific custom annotation view class, `TaskAnnotationView`
        // 💡 This is very similar to how we get and prepare cells for use in table views.
        
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: TaskAnnotationView.identifier, for: annotation) as? TaskAnnotationView else {
            fatalError("Unable to dequeue TaskAnnotationView")
        }
        
        // Configure the annotation view, passing in the task's image
        annotationView.configure(with: task.image)
        return annotationView
    }
}


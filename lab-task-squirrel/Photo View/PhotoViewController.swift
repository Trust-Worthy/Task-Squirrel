//
//  PhotoViewController.swift
//  lab-task-squirrel
//
//  Created by Trust-Worthy on 9/26/25.
//

import UIKit

class PhotoViewController: UIViewController {
    var task: Task!
    
    
    @IBOutlet weak var photoView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add this line for debugging
           print("PhotoViewController loaded. The task object is: \(String(describing: task))")

           // If the task is not nil, then set the image
           if task != nil {
               photoView.image = task.image
           } else {
               print("ERROR: Task object was not passed correctly and is nil.")
           }
        
        
        photoView.image = task.image
    }
}

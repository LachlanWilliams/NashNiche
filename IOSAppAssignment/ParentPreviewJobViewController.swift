//
//  PreviewJobViewController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 12/4/2024.
//

import UIKit
import MapKit

class ParentPreviewJobViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var theMap: MKMapView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var timeDateLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var job: Job? // Added property to hold job information

    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let job = job {
            // Populate UI with job information
            titleLabel.text = job.title
            locationLabel.text = job.location
            timeDateLabel.text = job.dateTime
            durationLabel.text = job.duration
            descriptionLabel.text = job.desc
            
            addMarkerForLocation(job.location!)
        }
        // Do any additional setup after loading the view.
    }
    

    @IBAction func postJob(_ sender: Any) {
        //performSegue(withIdentifier: <#T##String#>, sender: nil)
        self.dismiss(animated: true)
    }
    
    func addMarkerForLocation(_ location: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let placemark = placemarks?.first, let location = placemark.location {
                let mark = MKPlacemark(placemark: placemark)
                
                // Set region to display the marker
                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                self.theMap.setRegion(region, animated: true)
                
                // Add annotation
                self.theMap.addAnnotation(mark)
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

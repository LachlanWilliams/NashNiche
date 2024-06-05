//
//  NannyPreviewJobViewController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 12/4/2024.
//

import UIKit
import MapKit

class NannyPreviewJobViewController: UIViewController {

    var job: Job?
    
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var theMap: MKMapView!
    
    var listenerType = ListenerType.jobs
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        if let job = job {
            titleLabel.text = job.title
            dateTimeLabel.text = job.dateTime
            locationLabel.text = job.location
            durationLabel.text = job.duration
            descLabel.text = job.desc
            
            addMarkerForLocation(job.location!)
        }
        
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
    
    
    @IBAction func requestJob(_ sender: Any) {
        let currentPerson = databaseController?.currentPerson
        let newMessage = databaseController?.addMessage(text: "I am \(currentPerson?.fName! ?? "") \(currentPerson?.lName! ?? ""), I would like to request this job!", isNanny: true, job: job ?? Job())
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

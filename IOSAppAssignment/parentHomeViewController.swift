//
//  parentHomeViewController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 10/4/2024.
//

import UIKit
import MapKit

class parentHomeViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    
    @IBOutlet weak var durationPicker: UIDatePicker!
    
    @IBOutlet weak var descTextField: UITextField!
    
    @IBOutlet weak var theMap: MKMapView!
    
    weak var databaseController: DatabaseProtocol?
    
    let locationManager = CLLocationManager()
    
    var currentAnnotation: MKAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        locationManager.delegate = self
        
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        else {
            //locationBarButtonItem.isEnabled = (status == .authorizedWhenInUse)
            
        }
        
        //let configuration = MKStandardMapConfiguration()
        
        configureMapWithLocation("33 Thanet Street, VIC, 3144")
        
        // Set text field delegate
        locationTextField.delegate = self
        //theMap.preferredConfiguration = configuration

        //theMap.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func postJob(_ sender: Any) {
        let dateTime = dateTimePicker.date
        let duration = durationPicker.date
        guard let title = titleTextField.text, let location = locationTextField.text, let desc = descTextField.text else{
            return
        }
        if title.isEmpty || location.isEmpty || /*dateTime.isEmpty || duration.isEmpty ||*/ desc.isEmpty {
            var errorMsg = "Please ensure all fields are filled:\n"
            if title.isEmpty {
                errorMsg += "- provide a title\n"
            }
            if location.isEmpty {
                errorMsg += "- provide a location\n"
            }
//            if dateTime.isEmpty {
//                errorMsg += "- provide a dateTime\n"
//            }
//            if duration.isEmpty {
//                errorMsg += "- provide a duration\n"
//            }
            if desc.isEmpty {
                errorMsg += "- provide a desc\n"
            }
            
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }
        
        // Display confirmation alert
        let confirmAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to post this job?", preferredStyle: .alert)
        
        confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            // Add job to the database
            let _ = self.databaseController?.addJob(title: title, location: location, dateTime: dateTime.description, duration: duration.description, desc: desc)
            
            // Clear text fields
            self.titleTextField.text = ""
            self.locationTextField.text = ""
            self.descTextField.text = ""
            self.dateTimePicker.setDate(Date(), animated: true)
        }))
        
        confirmAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(confirmAlert, animated: true, completion: nil)
        //let _ = databaseController?.addJob(title: title, location: location, dateTime: dateTime, duration: duration, desc: desc)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == locationTextField {
            if let location = textField.text {
                // Update map with entered location
                configureMapWithLocation(location)
            }
        }
        
        return true
    }
    
    func configureMapWithLocation(_ location: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            // Remove old annotation
            if let annotation = self.currentAnnotation {
                self.theMap.removeAnnotation(annotation)
            }
            
            if let placemark = placemarks?.first, let location = placemark.location {
                let mark = MKPlacemark(placemark: placemark)
                
                var region = self.theMap.region
                
                region.center = location.coordinate
                region.span.longitudeDelta /= 8.0
                region.span.latitudeDelta /= 8.0
                self.theMap.setRegion(region, animated: true)
                
                // Add new annotation
                self.theMap.addAnnotation(mark)
                self.currentAnnotation = mark
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
